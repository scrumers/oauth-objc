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
@end


@implementation OADataFetcher

@synthesize response;
@synthesize responseData;

- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    request = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
	
    [request prepare];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection) {
		self.responseData = [NSMutableData data];
	} else {
		OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request response:nil didSucceed:NO];
		[delegate performSelector:didFailSelector withObject:ticket withObject:nil];
	}
}

- (void)dealloc {
	[responseData release], responseData = nil;
	[response release], response = nil;
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)theResponse {
	self.response = theResponse;
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
	
	BOOL success = [(NSHTTPURLResponse *)response statusCode] < 400;
	OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request response:response didSucceed:success];
	[delegate performSelector:didFinishSelector withObject:ticket withObject:responseData];
	
    self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connection release];
	
	OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:request response:response didSucceed:NO];
	[delegate performSelector:didFailSelector withObject:ticket withObject:error];
	
    self.responseData = nil;
}

@end
