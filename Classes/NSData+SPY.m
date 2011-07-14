//
//  NSData+SPY.m
//  Inspector
//
//  Created by Xiaochen Du on 7/14/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "NSData+SPY.h"


@implementation NSData (SPY)


- (NSString*) toString {

    return [[[NSString alloc] initWithData:self encoding:[NSString defaultCStringEncoding]] autorelease];

}

@end
