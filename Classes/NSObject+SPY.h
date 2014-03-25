//
//  NSObject+SPY.h
//  Inspector
//
//  Created by Xiaochen Du on 10/29/10.
//

#import <Foundation/Foundation.h>


@interface NSObject (SPY) 


/**
 * Return the root window
 */
- (UIWindow*) rootWindow;

/** 
 * Print the help. 
 */ 
- (NSString*) help; 

+ (NSString*) help;

/**
 * Return the definition of the class
 */
- (NSString*) defn;
- (NSString*) defnC : (Class) cls;
- (NSString*) defn: (NSString*) className;


/**
 * Return the long description that recursively list all ivars. Use visitedInstance dictionary to avoid infinit loop 
 */
- (NSString*) longDescription;

- (NSString*) jsonString;
@end
