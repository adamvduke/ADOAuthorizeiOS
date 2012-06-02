/*  ADTwitterOOBViewController.m
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 10/21/11.
 *  Copyright 2011 All rights reserved.
 */

#import "ADTwitterOOBViewController.h"

#define REQUEST_TOKEN_URL @"https://api.twitter.com/oauth/request_token"
#define ACCESS_TOKEN_URL @"https://api.twitter.com/oauth/access_token"
#define AUTHORIZE_TOKEN_URL @"https://api.twitter.com/oauth/authorize"

@implementation ADTwitterOOBViewController

#pragma mark -
#pragma mark Subclass overrides
- (NSString *)javascriptToLocateOAuthVerifier
{
    /* Javascript to get the value of <code>12345</code> element
     * This is really brittle and sucky
     */
    return @"var elements = document.getElementsByTagName('code'); \
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

#pragma mark -
#pragma mark UIWebViewDelegate overrides
- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    if(self.firstLoad)
    {
        [aWebView stringByEvaluatingJavaScriptFromString:@"window.scrollBy(0,200)"];
    }
    [super webViewDidFinishLoad:aWebView];
}



@end
