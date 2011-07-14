//
//  NSObject+SPY.m
//  Inspector
//
//  Created by Xiaochen Du on 10/29/10.
//

#import "NSObject+SPY.h"
#import "SPY.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import <malloc/malloc.h>

@implementation NSObject (SPY)

- (NSString*) help {
    
    NSArray* methods = [NSArray arrayWithObjects:
                            @"",
                            @"SPY functions you can use from NSObject:",
                            @" getSPY                     Return the SPY class.", 
                            @" defn                       Print the definition of the class.", 
                            @" defn:(NSString*) className Print the definition of the class with give name.",
                            @" rootWindow                 Return the root window."
                            @"",
                        nil];
                        
	return [methods componentsJoinedByString:@"\n"];
}

- (Class) getSPY {
	return [SPY class];
}


- (NSString*) defn {
	return [SPY defn:[self class]];
}

- (NSString*) defn: (NSString*) className {
	//
	Class cls = NSClassFromString(className);
	if (cls) {
		return [SPY defn:NSClassFromString(className)];
	} else {
		return [NSString stringWithFormat:@"No class for name: %@", className];
	}
}

- (UIView*) rootWindow {
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    return  keyWindow != nil ?  keyWindow : [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}

- (NSString*) description {

	NSMutableString* rtn = [NSMutableString stringWithFormat:@""];
	[rtn appendString:[self shortDescription]];
	[rtn appendFormat:@"{//Instance Variables\n%@", [self ivarDescription:nil recursive:NO]];
	
	return rtn;
}

- (NSString*) longDescription:(NSMutableSet*) visitedInstances {

    
    NSMutableString* rtn = [NSMutableString stringWithFormat:@""];
	[rtn appendString:[self shortDescription]];
    [rtn appendFormat:@"{//Instance Variables\n%@", [self ivarDescription: visitedInstances recursive:YES]];

        
	return rtn;
	
}


- (NSString*) shortDescription {
	return [NSString stringWithFormat:@"<%@:%x>\n", [[self class] description], &self]; 
}


- (NSString*) ivarDescription:(NSMutableSet*) visitedInstances recursive:(BOOL) recursive {

    if (visitedInstances == nil) {
        visitedInstances = [NSMutableSet set];
    }
    if ([visitedInstances containsObject:self]) {
        return @"";
    }
    
    //If haven't visted...
    
    [visitedInstances addObject:self];

    //recurisve...
    
    NSMutableString* ivarDescription = [NSMutableString string];
    
	unsigned int varCount;
    
	Ivar *vars = class_copyIvarList([self class],&varCount);
    
	if (varCount==0)
		return @"None";
    
	for (int i=0;i<varCount; i++) {
		Ivar var = vars[i];
        
		const char* name = ivar_getName(var);
        
		const char* type = ivar_getTypeEncoding(var);
        
		NSString* nameString = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
        
		NSString* typeString = [NSString stringWithCString:type encoding:NSASCIIStringEncoding];
        
		NSString* pureTypeString = [typeString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
		id object = [self valueForKey:nameString];
        
        if ([object isKindOfClass:[NSObject class]]) {
            NSString* description = [object longDescription:visitedInstances];
            NSString* tabbedDescription = [description stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"];
            [ivarDescription appendFormat:@"\nType:%@ Name:%@ Size:%zd Description:%@",pureTypeString,nameString,malloc_size(object),tabbedDescription];
            
        } else {
            // What happend to primary types?
        }
        
	}
    
	return ivarDescription;
    
}


@end
