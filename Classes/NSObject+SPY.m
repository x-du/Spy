//
//  NSObject+SPY.m
//  Inspector
//
//  Created by Xiaochen Du on 10/29/10.
//

#import "NSObject+SPY.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import <malloc/malloc.h>

@implementation NSObject (SPY)




- (NSString*) convertTypeS: (NSString*) t {
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


- (NSString*) spaces:(NSInteger) i {
    NSInteger tmp;
    NSMutableString* rtn = [NSMutableString stringWithCapacity:i];
    for (tmp = 0; tmp < i; tmp ++) {
        [rtn appendString: @" "];
    }
    return rtn;
}



- (NSString*) ivarDescription:(NSMutableSet*) visitedInstances recursive:(BOOL) recursive indentation:(NSInteger) indentation {
    
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
        
        NSString *nameString = [NSString stringWithCString:ivar_getName(var) encoding:NSASCIIStringEncoding];
		NSString *typeString = [NSString stringWithCString:ivar_getTypeEncoding(var) encoding:NSASCIIStringEncoding];
        
        //		const char* name = ivar_getName(var);
        //
        //		const char* type = ivar_getTypeEncoding(var);
        //
        //		NSString* nameString = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
        //
        //		NSString* typeString = [NSString stringWithCString:type encoding:NSASCIIStringEncoding];
        //
		NSString* pureTypeString = [typeString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        id object;
        //TODO: Check
        //[self valueForKey:@"_spinLock"] will throw exception
        if ([@"NSManagedObjectContext" isEqualToString:pureTypeString]) {
            continue;
        }
        object = [self valueForKey:nameString];
        if ([object isKindOfClass:[NSObject class]]) {
            NSString* description = [object longDescription:visitedInstances indentation:indentation];
            // NSString* tabbedDescription = [description stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"];
            [ivarDescription appendFormat:@"\n%@%@:%@ ",[self spaces:indentation], nameString, description];
            
        } else {
            // What happend to primary types?
        }
        
	}
    
	return ivarDescription;
    
}



+ (NSString*) helpSPY  {
    NSArray* methods = [NSArray arrayWithObjects:
                        @"SPY additions are added to the follow class. ",
                        @" NSObject",
                        @" NSData",
                        @" UIView",
                        nil];
	return [methods componentsJoinedByString:@"\n"];
}

+ (NSString*) help  {
    NSArray* methods = [NSArray arrayWithObjects:
                        @"SPY additions on NSObject :\n",
                        @" - rootWindow       Return the root window.",
                        @" - defnC:(Class)cls Return the definition of the class.",
                        @" - defn:(NSString*) Return the definition of the class.",
                        @" - defn             Return the defintion of the class.",
                        @" - longDescription  Return the description recursively.",
                        nil]; 
	return [NSString stringWithFormat:@"%@\n\n%@", [methods componentsJoinedByString:@"\n"], [self helpSPY]];	
}

- (NSString*) help {
    
    return [[self class] help];
}


- (UIWindow*) rootWindow {
	UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
	return  keyWindow != nil ?  keyWindow : [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}


//This method doesn't work if directly call from GDB. Call it from NSObject instance instead. 
- (NSString*) defnC : (Class) cls{
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
		
		NSString *methodNameString = [NSString stringWithCString:sel_getName(selector) encoding:NSASCIIStringEncoding];
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
		NSString *methodNameString = [NSString stringWithCString:sel_getName(selector) encoding:NSASCIIStringEncoding];
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


- (NSString*) defn {
	return [NSObject defnC:[self class]];
}

- (NSString*) defn: (NSString*) className {
	//
	Class cls = NSClassFromString(className);
	if (cls) {
		return [NSObject defnC:NSClassFromString(className)];
	} else {
		return [NSString stringWithFormat:@"No class for name: %@", className];
	}
}



- (NSString*) longDescription:(NSMutableSet*) visitedInstances indentation:(NSInteger) indentation {
    
    NSString* desc = [self description];
    NSString* defaultDescriptionRegex = @"<\\S+:\\s0x\\S+>";
	NSPredicate* test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",defaultDescriptionRegex];
	if ([test evaluateWithObject:desc]) {
        //the desc is in the default format, print the ivar
        NSMutableString* rtn = [NSMutableString stringWithFormat:@""];
        [rtn appendString:desc];
        
        NSString* ivarDesc = [self ivarDescription: visitedInstances recursive:YES indentation:indentation+1];
        if ([@"" compare:ivarDesc]) {

            [rtn appendFormat:@"\n%@{%@\n%@}", [self spaces:indentation], ivarDesc, [self spaces:indentation]];
        } 
        return rtn;
    }
    return desc;
    
}


- (NSString*) longDescription {
    return [self longDescription:nil indentation:0];
}

- (NSString*) jsonString {
    
    NSError *error;
    if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (! jsonData) {
            //NSLog(@"Got an error: %@", error);
            return @"";
        } else {
            return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
        }
    } else {
        //NSLog(@"Got an error: %@", error);
        return @"";
    }
}

@end
