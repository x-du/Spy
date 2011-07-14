//
//  NSURLConnection+SPY.h
//  Inspector
//
//  Created by Xiaochen Du on 1/28/11.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (SPY) 

+ (void) methodSwizzle;

- (id)initWithRequest2:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;

@end
