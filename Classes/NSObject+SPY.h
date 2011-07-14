//
//  NSObject+SPY.h
//  Inspector
//
//  Created by Xiaochen Du on 10/29/10.
//

#import <Foundation/Foundation.h>


@interface NSObject (SPY) 
- (NSString*) help;
- (Class) getSPY;
- (NSString*) defn;
- (NSString*) defn: (NSString*) className;
- (UIView*) rootWindow;

/**
 * Return the short description of the object, similar to default NSObject description. 
 */
- (NSString*) shortDescription;

/**
 * Return the long description that recursively list all ivars. Use visitedInstance dictionary to avoid infinit loop 
 */
- (NSString*) longDescription:(NSMutableSet*) visitedInstances;

/**
 Return the description of the ivars
 */
- (NSString*) ivarDescription:(NSMutableSet*) visitedInstances recursive:(BOOL) recursive;
	
@end
