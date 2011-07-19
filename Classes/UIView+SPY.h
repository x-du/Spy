//
//  UIView+SPY.h
//  Inspector
//
//  Created by Xiaochen Du on 10/28/10.
//

#import <Foundation/Foundation.h>


@interface UIView (SPY)
+ (NSString*) help;
//- (NSString*) help;
- (NSString*) printTree:(int) indent;
- (NSString*) printTree;

@end
