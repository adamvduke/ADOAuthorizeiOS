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
    /* Javascript to get the value of <code>12345</code> element
     * This is really brittle and sucky
     */
    return @"var elements = document.getElementsByTagName('code'); \
    var element = elements[0]; \
    var pin = null; \
    if (element) pin = element.innerHTML;";
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    if(self.firstLoad)
    {
        [aWebView stringByEvaluatingJavaScriptFromString:@"window.scrollBy(0,200)"];
    }
    [super webViewDidFinishLoad:aWebView];
}

@end
