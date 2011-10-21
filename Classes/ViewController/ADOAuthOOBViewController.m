/*  ADOAuthOOBViewController.m
 *  ADOAuthorizeiOS
 *
 *  Created by Adam Duke on 1/13/11.
 *  Copyright 2011 All rights reserved.
 */

#import "ADOAuthOOBViewController.h"
#import "ADSharedMacros.h"
#import "OAConsumer.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"
#import "OAServiceTicket.h"
#import "OAToken.h"
#import "TTMacros.h"

@interface ADOAuthOOBViewController ()

- (void)fetchRequestToken;
- (void)fetchAccessToken;
- (void)requestURL:(NSURL *)url token:(OAToken *)token onSuccess:(SEL)success onFail:(SEL)fail;
- (void)loadAuthorizeRequest;
- (NSString *)locateOAuthVerifierInWebView:(UIWebView *)aWebView;
- (void)locatedVerifier:(NSString *)pin;
- (NSURLRequest *)generateAuthorizeURLRequest;

@property(nonatomic,retain)NSURL *requestTokenURL;
@property(nonatomic,retain)NSURL *accessTokenURL;
@property(nonatomic,retain)NSURL *authorizeURL;

@end

@implementation ADOAuthOOBViewController

@synthesize webView, delegate, verifier, requestTokenURL, accessTokenURL, authorizeURL;

#pragma mark -
#pragma mark UIViewController life cycle

- (id)   initWithConsumerKey:(NSString *)key
              consumerSecret:(NSString *)secret
       requestTokenURLString:(NSString *)requestTokenURLString
        accessTokenURLString:(NSString *)accessTokenURLString
          authorizeURLString:(NSString *)authorizeURLString
                    delegate:(id<ADOAuthOOBViewControllerDelegate>)aDelegate
{
	self = [super initWithNibName:nil bundle:nil];
	if(self)
	{
		self.delegate = aDelegate;
		consumer = [[OAConsumer alloc] initWithKey:key secret:secret];
		self.requestTokenURL = [NSURL URLWithString:requestTokenURLString];
		self.accessTokenURL = [NSURL URLWithString:accessTokenURLString];
		self.authorizeURL = [NSURL URLWithString:authorizeURLString];
		firstLoad = YES;
	}
	return self;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(consumer);
	TT_RELEASE_SAFELY(requestTokenURL);
	TT_RELEASE_SAFELY(requestToken);
	TT_RELEASE_SAFELY(accessTokenURL);
	TT_RELEASE_SAFELY(authorizeURL);
	TT_RELEASE_SAFELY(webView);
	TT_RELEASE_SAFELY(verifier);
	[super dealloc];
}

/* Implement loadView to create a view hierarchy programmatically, without using a nib. */
- (void)loadView
{
	NSLog(@"Loading ADOAuthOOBViewController...");

	[super loadView];
	self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)] autorelease];
	webView.delegate = self;
	[self.view addSubview:webView];
}

- (void)viewDidLoad
{
	[self fetchRequestToken];
}

/* Override to allow orientations other than the default portrait orientation. */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	/* Releases the view if it doesn't have a superview. */
	[super didReceiveMemoryWarning];

	/* Release any cached data, images, etc. that aren't in use. */
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark -
#pragma mark OAuth workflow

/* A request token is used to generate a URL request with the authorizeURL
 * as it's base URL. The resulting request is then loaded and presented
 * to the user to "authorize" the application to connect to his/her account
 */
- (void)fetchRequestToken
{
	[self requestURL:self.requestTokenURL
	           token:nil
	       onSuccess:@selector(setRequestToken:withData:)
	          onFail:@selector(outhTicketFailed:data:)];
}

/*
 * request token callback
 * when the OADataFetcher created from a call to fetchRequestToken
 * recieves a successful response this method will be called to parse the
 * data and set the requestToken ivar
 */
- (void)setRequestToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
	if(!ticket.didSucceed || !data)
	{
		return;
	}

	NSString *dataString = [[[NSString alloc] initWithData:data
	                                              encoding:NSUTF8StringEncoding] autorelease];
	if(!dataString)
	{
		return;
	}

	[requestToken release];
	requestToken = [[OAToken alloc] initWithHTTPResponseBody:dataString];
	if(verifier.length)
	{
		requestToken.verifier = verifier;
	}
	[self loadAuthorizeRequest];
}

/* causes the webView to load a url request that will allow the user to authorize
 * access to his/her account
 */
- (void)loadAuthorizeRequest
{
	NSURLRequest *request = [self generateAuthorizeURLRequest];
	[webView loadRequest:request];
}

/* An access token is used to "sign" requests to the api. The access token
 * is what is returned from a call to the authorize URL with a valid request
 * token, after the user has "authorized" the application to connect to his
 * or her account
 */
- (void)fetchAccessToken
{
	[self requestURL:self.accessTokenURL
	           token:requestToken
	       onSuccess:@selector(setAccessToken:withData:)
	          onFail:@selector(outhTicketFailed:data:)];
}

/*
 * when the OADataFetcher created from a call to fetchRequestToken
 * recieves a successful response, this method will be called to parse the
 * data and set the accessToken ivar
 */
- (void)setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
	if(!ticket.didSucceed || !data)
	{
		return;
	}

	NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if(!dataString)
	{
		return;
	}
	if(verifier.length && [dataString rangeOfString:@"oauth_verifier"].location == NSNotFound)
	{
		dataString = [dataString stringByAppendingFormat:@"&oauth_verifier=%@", verifier];
	}
	[delegate authCompletedWithData:dataString orError:nil];
}

#pragma mark -
#pragma mark OAuth helper methods
- (void)requestURL:(NSURL *)url token:(OAToken *)token onSuccess:(SEL)success onFail:(SEL)fail
{
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
	                                                                consumer:consumer
	                                                                   token:token
	                                                                   realm:nil
	                                                       signatureProvider:nil] autorelease];
	if(!request)
	{
		return;
	}
	if(verifier.length)
	{
		token.verifier = verifier;
	}
	[request setHTTPMethod:@"POST"];
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
	[fetcher fetchDataWithRequest:request delegate:self didFinishSelector:success didFailSelector:fail];
}

/*
 * if the fetch fails this is what will happen
 * you'll want to add your own error handling here.
 *
 */
- (void)outhTicketFailed:(OAServiceTicket *)ticket data:(NSData *)data
{
	/* TODO: create an approprite NSError to return here */
	NSLog(@"the ticket failed to load...");
	[delegate authCompletedWithData:nil orError:nil];
}

/* This generates a URL request that can be passed to a UIWebView. It will open a page in which the
 * user must enter their Twitter creds to validate */
- (NSURLRequest *)generateAuthorizeURLRequest
{
	if(!requestToken.key && requestToken.secret)
	{
		NSLog(@"can't create an authorize request without a request token...");

		/* we need a valid request token to generate the URL */
		return nil;
	}
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:self.authorizeURL
	                                                                consumer:nil
	                                                                   token:requestToken
	                                                                   realm:nil
	                                                       signatureProvider:nil] autorelease];
	OARequestParameter *oauth_token = [[[OARequestParameter alloc] initWithName:@"oauth_token"
	                                                                      value:requestToken.key] autorelease];
	[request setParameters:[NSArray arrayWithObject:oauth_token]];
	return request;
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

/* TODO: possibly implement the following delegate methods
 * - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 * navigationType:(UIWebViewNavigationType)navigationType;
 * - (void)webViewDidStartLoad:(UIWebView *)webView;
 * - (void)webViewDidFinishLoad:(UIWebView *)webView;
 * - (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
 */

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	NSLog(@"Finished loading the webview");
	if(firstLoad)
	{
		[aWebView stringByEvaluatingJavaScriptFromString:@"window.scrollBy(0,200)"];
		firstLoad = NO;
		return;
	}
	NSString *authPin = [self locateOAuthVerifierInWebView:aWebView];
	if(authPin.length)
	{
		[self locatedVerifier:authPin];
		return;
	}
}

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

	/* use javascript to get the value of the 'oauth_pin' element */
	NSString *js = @"var d = document.getElementById('oauth_pin'); if (d) d = d.innerHTML;";
	NSString *pin = [aWebView stringByEvaluatingJavaScriptFromString:js];
	return pin;
}

- (void)locatedVerifier:(NSString *)aVerifier
{
	self.verifier = aVerifier;
	[self fetchAccessToken];
}

@end
