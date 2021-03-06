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
- (void)authCompletedWithData:(NSString *)date orError:(NSError *)error;
- (void)authCancelled;
@property (nonatomic, retain) NSURL *requestTokenURL;
@property (nonatomic, retain) NSURL *accessTokenURL;
@property (nonatomic, retain) NSURL *authorizeURL;

@end

@implementation ADOAuthOOBViewController

@synthesize webView, delegate, verifier, requestTokenURL, accessTokenURL, authorizeURL, toolBar, firstLoad;

#pragma mark -
#pragma mark UIViewController life cycle

- (id)initWithConsumerKey:(NSString *)key
           consumerSecret:(NSString *)secret
                 delegate:(id<ADOAuthOOBViewControllerDelegate>)aDelegate
{
    self = self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        self.delegate = aDelegate;
        consumer = [[OAConsumer alloc] initWithKey:key secret:secret];
        self.requestTokenURL = [NSURL URLWithString:[self requestTokenURLString]];
        self.accessTokenURL = [NSURL URLWithString:[self accessTokenURLString]];
        self.authorizeURL = [NSURL URLWithString:[self authorizeTokenURLString]];
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

- (void)authCompletedWithData:(NSString *)data orError:(NSError *)error
{
    [delegate authCompletedWithData:data orError:error];
}

- (void)authCancelled
{
    [delegate authCancelled];
}

- (UIToolbar *)toolBar
{
    if(!toolBar)
    {
        CGRect toolBarFrame = CGRectMake(0, -1, 320, 44);
        self.toolBar = [[[UIToolbar alloc] initWithFrame:toolBarFrame] autorelease];
        UIBarButtonItem *cancelItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(authCancelled)] autorelease];
        self.toolBar.items = [NSArray arrayWithObject:cancelItem];
    }
    return toolBar;
}

- (UIWebView *)webView
{
    if(!webView)
    {
        self.webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 43, 320, 417)] autorelease];
        webView.delegate = self;
    }
    return webView;
}

/* Implement loadView to create a view hierarchy programmatically, without using a nib. */
- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.webView];
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
    [self authCompletedWithData:dataString orError:nil];
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
    [self authCompletedWithData:nil orError:nil];
}

/* This generates a URL request that can be passed to a UIWebView. It will open a page in which the
 * user must enter their Twitter creds to validate */
- (NSURLRequest *)generateAuthorizeURLRequest
{
    if(!requestToken.key && requestToken.secret)
    {
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
    if(firstLoad)
    {
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

- (NSString *)javascriptToLocateOAuthVerifier
{
    /* Each OAuth provider is going to need a different implementation
     * to scrape the pin out of the web view.
     */
    [NSException raise:@"ADOAuthMethodNotImplementedException" format:@"[%@]:%@", [[self class] description], NSStringFromSelector(_cmd)];
    return nil;
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
    NSString *javaScript = [self javascriptToLocateOAuthVerifier];
    NSString *pin = [aWebView stringByEvaluatingJavaScriptFromString:javaScript];
    return pin;
}

- (void)locatedVerifier:(NSString *)aVerifier
{
    self.verifier = aVerifier;
    [self fetchAccessToken];
}

/* Subclasses MUST override this method if they want to use the convenience initializer.
 * Default implementation raises an exception
 */
- (NSString *)requestTokenURLString
{
    /* Each OAuth provider is going to need a different implementation
     * to scrape the pin out of the web view.
     */
    [NSException raise:@"ADOAuthMethodNotImplementedException" format:@"[%@]:%@", [[self class] description], NSStringFromSelector(_cmd)];
    return nil;
}

/* Subclasses MUST override this method if they want to use the convenience initializer.
 * Default implementation raises an exception
 */
- (NSString *)accessTokenURLString
{
    /* Each OAuth provider is going to need a different implementation
     * to scrape the pin out of the web view.
     */
    [NSException raise:@"ADOAuthMethodNotImplementedException" format:@"[%@]:%@", [[self class] description], NSStringFromSelector(_cmd)];
    return nil;
}

/* Subclasses MUST override this method if they want to use the convenience initializer.
 * Default implementation raises an exception
 */
- (NSString *)authorizeTokenURLString
{
    /* Each OAuth provider is going to need a different implementation
     * to scrape the pin out of the web view.
     */
    [NSException raise:@"ADOAuthMethodNotImplementedException" format:@"[%@]:%@", [[self class] description], NSStringFromSelector(_cmd)];
    return nil;
}

@end
