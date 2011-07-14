//
//  SPY.m
//  Inspector
//
//  Created by Xiaochen Du on 11/20/10.
//

#import "SPY.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
//#import <objc/Protocol.h>

@implementation SPY 

+ (void) initialize {
}


+ (NSString*) convertTypeS: (NSString*) t {
    NSString* rtn = t;
    if ([t length] >=3) {
        if ([t hasPrefix: @"@"]) {
            rtn = [NSString stringWithFormat:@"%@ *", [t substringWithRange:NSMakeRange(2, t.length-3)]]; 
        }
    } else {
        if ([t isEqualToString:@"c"]) rtn = @"BOOL";
        else if ([t isEqualToString:@"i"]) rtn = @"NSInteger";
        else if ([t isEqualToString:@"v"]) rtn = @"void";  
        else if ([t isEqualToString:@"@"]) rtn = @"id";
    }
    return rtn;
}

+ (NSString*) help  {
    NSArray* methods = [NSArray arrayWithObjects:
                        @"\nFunctions you can use from SPY Class. You can always call help on any NSObject.\n",
                        @" rootWindow       Return the root window.",
                        @" defn:(Class)cls  Return the	definition of the class.",
                        @" NSData2String:(NSData*) Convert NSData to NSString.",
                        @" logToConsole:(BOOL) Log MicroStrategy Log record to concole or not. Default: YES.",
						@" traceRequests:(BOOL) Trace Request layer to concole. The default is YES",
						@" traceServices:(BOOL) Trace Services layer to concole. The default YES",
						@" traceXMLParsing:(BOOL) Trace XML Parsing. The default is YES. ",
                        nil]; 
	return [methods componentsJoinedByString:@"\n"];	
}

+ (UIWindow*) rootWindow {
	UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
	return  keyWindow != nil ?  keyWindow : [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}


//This method doesn't work if directly call from GDB. Call it from NSObject instance instead. 
+ (NSString*) defn : (Class) cls{
	//NSLog(@"Calling SPY's defn");
	NSMutableString* rtn = [NSMutableString stringWithFormat:@""];
                            
	unsigned int count = 0;
	
    //Class, Super class
    Class superCls = class_getSuperclass(cls);
 	//[rtn appendFormat:@"Class Name:%@ Super Class:%@\n", [cls description], [superCls description]];
    
    // protocol
    Protocol** protocols = class_copyProtocolList(cls, &count);
    NSMutableArray* protStrings = [[NSMutableArray alloc] init];
    for (int i=0;i<count;i++) {
        Protocol* prot = protocols[i];
        [protStrings addObject: [NSString stringWithCString:(const char *)[prot name] encoding:NSASCIIStringEncoding]];
    }
    //[rtn appendFormat:@"Protocol: %@\n", [protStrings componentsJoinedByString:@", "]];
    if (protocols) {
        free(protocols);
    }
    
    [rtn appendFormat:@"@interface %@ : %@ < %@ >\n", [cls description], [superCls description], [protStrings componentsJoinedByString:@", "]];
    [protStrings release];
    [rtn appendFormat:@"{\n"];
	////// Ivar
    //[rtn appendFormat:@"Instance Variables:\n"];
    Ivar* ivars = class_copyIvarList(cls, &count);
    for (int i=0; i < count; i++) {
		
		Ivar ivar = ivars[i];
		NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSASCIIStringEncoding];
		NSString *ivarType = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSASCIIStringEncoding];
        
		[rtn appendFormat:@"  %@ %@;\n", [self convertTypeS:ivarType], ivarName];
		
	}
	if (ivars) {
		free(ivars);
	} 
    [rtn appendFormat:@"}\n"];
        
	//[rtn appendFormat:@"Class Methods:\n"];
	// Get all class methods for UIColor. If we wanted instance methods instead, we'd just pass [UIColor class] as the first argument.
	Method *methods = class_copyMethodList(object_getClass(cls), &count);
	for (int i=0; i < count; i++) {
		
		Method method = methods[i];
		
//		NSMutableString* argStr = [NSMutableString stringWithString:@""];
//		
//		unsigned int numberOfArguments = method_getNumberOfArguments(method);
//		for (int j=0;j<numberOfArguments;j++) {
//			char* argumentType;
//			size_t len;
//			method_getArgumentType(method, j, argumentType, &len);
//			[argStr appendString:[NSString stringWithCString:argumentType encoding:NSASCIIStringEncoding]];
//		}
		
		
		SEL selector = method_getName(method);
		
		NSString *methodNameString = [NSString stringWithCString:(const char *)selector encoding:NSASCIIStringEncoding];
		char returnType;
		method_getReturnType(method, &returnType, 1);
		
		[rtn appendFormat:@" +  (%@) %@ \n",  [self convertTypeS:[NSString stringWithFormat:@"%c", returnType]], methodNameString];
		
	}
	if (methods) {
		free(methods);
	} 
	
	//[rtn appendFormat:@"Instance Methods:\n"];
	methods = class_copyMethodList(cls, &count);
	//Method *methods = class_copyMethodList(object_getClass([self class]), &count);
	for (int i=0; i < count; i++) {
		
		Method method = methods[i];
		SEL selector = method_getName(method);
		NSString *methodNameString = [NSString stringWithCString:(const char *)selector encoding:NSASCIIStringEncoding];
		char returnType;
		method_getReturnType(method, &returnType, 1);
		
		[rtn appendFormat:@" - (%@) %@\n", [self convertTypeS:[NSString stringWithFormat:@"%c", returnType]], methodNameString];
		
	}
	if (methods) {
		free(methods);
	} 
	
    //////
	//[rtn appendFormat:@"Properties:\n"];
	objc_property_t* properties = class_copyPropertyList(cls, &count);
	for (int i=0; i < count; i++) {
		
		objc_property_t prop = properties[i];
		NSString *propNameString = [NSString stringWithCString:property_getName(prop) encoding:NSASCIIStringEncoding];
		NSString *propAttributesString = [NSString stringWithCString:property_getAttributes(prop) encoding:NSASCIIStringEncoding];

		[rtn appendFormat:@"@property  %@ %@\n", propNameString, propAttributesString];
		
	}
	if (properties) {
		free(properties);
	} 
	[rtn appendFormat:@"@end\n"];
	return rtn;
}


@end
