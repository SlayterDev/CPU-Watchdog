//
//  SytemInfo.h
//  iTop
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>
#include "Meter.h"

@class SystemInfo;

@protocol SystemInfoDelegate

-(void) systemInfo:(SystemInfo *)sysinfo didUpdateCPU:(NSArray *)usages;

@end

@interface SystemInfo : NSObject {
	processor_info_array_t cpuInfo, prevCpuInfo;
	mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
	unsigned numCPUs;
	NSTimer *updateTimer;
	NSLock *CPUUsageLock;
}

@property (nonatomic, strong) Meter *CPUBar;
@property (nonatomic, strong) id<SystemInfoDelegate> delegate;

+(SystemInfo *) standardInfo;
+(SystemInfo *) widgetInfo;
-(void) stopTimer;
-(void) beginTrackingCPU;
-(int) getNumCPUs;
-(CGFloat) totalMemory;
-(CGFloat) freeMemory;
-(NSArray *) getProcesses;
-(NSDate *) uptime;
-(NSDictionary *) getDiskInfo;

@end
