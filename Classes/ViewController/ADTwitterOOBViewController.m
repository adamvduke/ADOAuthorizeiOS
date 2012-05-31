/*  ADTwitterOOBViewController.m
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 10/21/11.
 *  Copyright 2011 All rights reserved.
 */

#import "ADTwitterOOBViewController.h"

@implementation ADTwitterOOBViewController

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
