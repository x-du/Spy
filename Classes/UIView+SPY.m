//
//  UIView+SPY.m
//  Inspector
//
//  Created by Xiaochen Du on 10/28/10.
//
#import "NSObject+SPY.h"
#import "UIView+SPY.h"
#import <objc/runtime.h>

#define INPROGRESS


@implementation UIView (SPY)

- (NSString*) help {
    NSArray* methods = [NSArray arrayWithObjects:
                        @"",
                        @"SPY additions on UIView:",
                        @" printTree:(int)      Print the view tree, with initial indentation.",
                        @" printTree            Print the view tree.",
                        @"",
                        nil];
//    return [methods componentsJoinedByString:@"\n"];
	return [NSString stringWithFormat:@"%@\n%@",[methods componentsJoinedByString:@"\n"], [NSObject help]];
}


-(NSString*) printTree:(int) indent {
	
	NSMutableString* rtn = [NSMutableString stringWithFormat:@""];
	

	[rtn appendString:@"\n"];
	for (int i=0;i<indent;i++) {
		[rtn appendString:@" "];
	}
	
	[rtn appendString:[self description]];
	//[rtn appendFormat:@",frame=(%0.0f, %0.0f, %0.0f, %0.0f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height];
	
	for (int i=0;i<[[self subviews] count];i++) {
		[rtn appendString:[[[self subviews] objectAtIndex:i] printTree:indent+2]];
	}
	
	
	return rtn;
}

-(NSString*) printTree {
	
	return [self printTree:0];
}

@end
