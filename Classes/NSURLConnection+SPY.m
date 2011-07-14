//
//  NSURLConnection+SPY.m
//  Inspector
//
//  Created by Xiaochen Du on 1/28/11.
//

#import "NSURLConnection+SPY.h"
#import "NSData+SPY.h"
#import <objc/runtime.h>

@implementation NSURLConnection (SPY)


- (id)initWithRequest2:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
	
	//Tracing:
	NSLog(@"Request URL:%@", [request URL]);
	NSLog(@"HTTP Body:%@", [[request HTTPBody] toString]);
	NSLog(@"HTTP Method:%@", [request HTTPMethod]);
	NSLog(@"All HTTP Header:%@", [request allHTTPHeaderFields]);
		
	return [self initWithRequest2:request delegate:delegate startImmediately:startImmediately];
}


+ (void) initialize {
	[self methodSwizzle];
}



+ (void) methodSwizzle {
	
	if (self == [NSURLConnection class]) {
		
        Method originalMethod = class_getInstanceMethod([NSURLConnection class], @selector(initWithRequest:delegate:startImmediately:));
        Method replacedMethod = class_getInstanceMethod([NSURLConnection class], @selector(initWithRequest2:delegate:startImmediately:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
	}
}


@end
