//
//  SytemInfo.m
//  iTop
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import "SystemInfo.h"

@implementation SystemInfo

+(SystemInfo *) standardInfo {
	static SystemInfo *sharedHelper = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedHelper = [[self alloc] init];
	});
	return sharedHelper;
}

+(SystemInfo *) widgetInfo {
	static SystemInfo *sharedHelper = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedHelper = [[self alloc] init];
	});
	return sharedHelper;
}

-(void) beginTrackingCPU {
	int mib[2U] = { CTL_HW, HW_NCPU };
	size_t sizeOfNumCPUs = sizeof(numCPUs);
	int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
	if (status)
		numCPUs = 1;
	
	CPUUsageLock = [[NSLock alloc] init];
	
	NSLog(@"Attempting to set timer");
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateCPU:) userInfo:nil repeats:YES];
}

-(void) updateCPU:(NSTimer *)timer {
	natural_t numCPUsU = 0U;
	kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
	
	if (err == KERN_SUCCESS) {
		[CPUUsageLock lock];
		float avg = 0;
		
		NSMutableArray *usages = [NSMutableArray array];
		for (unsigned i = 0U; i < numCPUs; i++) {
			float inUse, total;
			if (prevCpuInfo) {
				inUse = (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
					+ (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
					+ (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]);
				total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
			} else {
				inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
				total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
			}
			
			//NSLog(@"Core: %u Usage: %f", i, inUse/total);
			avg += inUse/total;
			
			[usages addObject:[NSNumber numberWithFloat:inUse/total]];
		}
		
		[CPUUsageLock unlock];
		
		[self.delegate systemInfo:self didUpdateCPU:usages];
		
		if (prevCpuInfo) {
			size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
			vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
		}
		
		prevCpuInfo = cpuInfo;
		numPrevCpuInfo = numCpuInfo;
		
		cpuInfo = NULL;
		numCpuInfo = 0U;
	} else {
		NSLog(@"Error");
		[timer invalidate];
	}
}

-(int) getNumCPUs {
	return  numCPUs;
}

-(NSArray *) getProcesses {
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
	unsigned int miblen = 4;
	
	size_t size;
	int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
	
	struct kinfo_proc * process = NULL;
	struct kinfo_proc * newprocess = NULL;
	
	do {
		
		size += size / 10;
		newprocess = realloc(process, size);
		
		if (!newprocess){
			
			if (process){
				free(process);
			}
			
			return nil;
		}
		
		process = newprocess;
		st = sysctl(mib, miblen, process, &size, NULL, 0);
		
	} while (st == -1 && errno == ENOMEM);
	
	if (st == 0){
		
		if (size % sizeof(struct kinfo_proc) == 0){
			unsigned long nprocess = size / sizeof(struct kinfo_proc);
			
			if (nprocess){
				
				NSMutableArray * array = [[NSMutableArray alloc] init];
				
				for (long i = nprocess - 1; i >= 0; i--){
					
					NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
					NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
					NSString *ppid = [NSString stringWithFormat:@"%d", process[i].kp_eproc.e_ppid];
					
					NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, ppid, nil]
																		forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", @"ppid", nil]];
					[array addObject:dict];
				}
				
				free(process);
				return array;
			}
		}
	}
	
	return nil;
}

-(NSDate *) uptime {
	struct timeval boottime;
	int mib[2] = {CTL_KERN, KERN_BOOTTIME};
	size_t size = sizeof(boottime);
	time_t now;
	time_t uptime = -1;
	
	(void)time(&now);
	
	if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0)
	{
		uptime = now - boottime.tv_sec;
	}
	NSDate *uptimeDate = [NSDate date];
	
	return uptimeDate;
}

@end
