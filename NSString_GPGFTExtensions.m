//
//  NSString_GPGFTExtensions.m
//  GPGFileTool
//
//  Created by Gordon Worley on Sun Dec 08 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "NSString_GPGFTExtensions.h"


@implementation NSString (GPGFTExtensions)

- (NSString *)unixAsMacPath
{
    char *str;
    int i;

    str = [self cString];
    for (i = 0; i < [self length]; i++)
        if (*(str + i) == '/')
            *(str + i) = ':';

    return [NSString stringWithCString: str];
}

@end
