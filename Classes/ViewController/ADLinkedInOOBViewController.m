/*  ADLinkedInOOBViewController.m
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 5/30/12.
 *  Copyright 2011 All rights reserved.
 */

#import "ADLinkedInOOBViewController.h"

#define REQUEST_TOKEN_URL @"https://api.linkedin.com/uas/oauth/requestToken"
#define ACCESS_TOKEN_URL @"https://api.linkedin.com/uas/oauth/accessToken"
#define AUTHORIZE_TOKEN_URL @"https://www.linkedin.com/uas/oauth/authorize"

@implementation ADLinkedInOOBViewController

#pragma mark -
#pragma mark Subclass overrides
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

/* Subclasses MUST override this method.
 * Default implementation raises an exception
 */
- (NSString *)requestTokenURLString
{
    return REQUEST_TOKEN_URL;
}

/* Subclasses MUST override this method.
 * Default implementation raises an exception
 */
- (NSString *)accessTokenURLString
{
    return ACCESS_TOKEN_URL;
}

/* Subclasses MUST override this method.
 * Default implementation raises an exception
 */
- (NSString *)authorizeTokenURLString
{
    return AUTHORIZE_TOKEN_URL;
}

@end
