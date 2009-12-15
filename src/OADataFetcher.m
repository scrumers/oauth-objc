//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OADataFetcher.h"


@interface OADataFetcher ()
@property(nonatomic, retain) NSURLResponse *response;
@property(nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) OAMutableURLRequest *request;
@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) SEL didFinishSelector;
@property(nonatomic, assign) SEL didFailSelector;
@end


@implementation OADataFetcher

@synthesize connection;
@synthesize response;
@synthesize responseData;
@synthesize request;
@synthesize delegate;
@synthesize didFinishSelector;
@synthesize didFailSelector;

+ (id)fetcherWithRequest:(OAMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
	fetcher.request = aRequest;
	fetcher.delegate = aDelegate;
	fetcher.didFinishSelector = finishSelector;
	fetcher.didFailSelector = failSelector;
	return fetcher;
}

- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    self.request = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
    [self fetchData];
}

- (void)fetchData {
    [request prepare];
	
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	if (connection) {
		self.responseData = [NSMutableData data];
	} else {
		OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request response:nil didSucceed:NO];
		[delegate performSelector:didFailSelector withObject:ticket withObject:nil];
		[ticket release];
	}
}

- (void)dealloc {
	[connection release], connection = nil;
	[responseData release], responseData = nil;
	[response release], response = nil;
	[request release], request = nil;
	[super dealloc];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse {
	self.response = theResponse;
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
	BOOL success = [(NSHTTPURLResponse *)response statusCode] < 400;
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request response:response didSucceed:success];
	[delegate performSelector:didFinishSelector withObject:ticket withObject:responseData];
	[ticket release];
	
    self.connection = nil;
    self.response = nil;
    self.responseData = nil;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request response:response didSucceed:NO];
	[delegate performSelector:didFailSelector withObject:ticket withObject:error];
	[ticket release];
	
	self.connection = nil;
    self.response = nil;
    self.responseData = nil;
}

@end
