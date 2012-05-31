/*  ADLinkedInOOBViewController.m
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 5/30/12.
 *  Copyright 2011 All rights reserved.
 */

#import "ADLinkedInOOBViewController.h"

@implementation ADLinkedInOOBViewController

- (NSString *)javascriptToLocateOAuthVerifier
{
    /* Javascript to get the value of the element with the css class 'access-code'
     * This is really brittle and sucky
     */
    return @"var elements = document.getElementsByClassName('access-code'); \
    var element = elements[0]; \
    var pin = null; \
    if (element) pin = element.innerHTML;";
}

@end
