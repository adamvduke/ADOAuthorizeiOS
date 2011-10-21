/*  ADTwitterOOBViewController.m
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 10/21/11.
 *  Copyright 2011 All rights reserved.
 */

#import "ADTwitterOOBViewController.h"
#import "ADSharedMacros.h"

@implementation ADTwitterOOBViewController

- (NSString *)locateOAuthVerifierInWebView:(UIWebView *)aWebView
{
	/* if the web view doesn't have any content
	 * return nil
	 */
	NSString *html = [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
	if( IsEmpty(html) )
	{
		return nil;
	}
    
	/* Use javascript to get the value of <code>12345</code> element
     * This is really brittle and sucky
     */
    NSString *javaScript = @"var elements = document.getElementsByTagName('code'); \
    var element = elements[0]; \
    var pin = null; \
    if (element) pin = element.innerHTML;";
    NSString *pin = [aWebView stringByEvaluatingJavaScriptFromString:javaScript];
	return pin;
}

@end
