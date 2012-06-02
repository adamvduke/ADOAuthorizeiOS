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

- (id)initWithConsumerKey:(NSString *)key
           consumerSecret:(NSString *)secret
                 delegate:(id<ADOAuthOOBViewControllerDelegate>)aDelegate
{
    self = [super initWithConsumerKey:key
                       consumerSecret:secret
                requestTokenURLString:REQUEST_TOKEN_URL
                 accessTokenURLString:ACCESS_TOKEN_URL
                   authorizeURLString:AUTHORIZE_TOKEN_URL
                             delegate:aDelegate];
    if(self)
    {
    }
    return self;
}

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
