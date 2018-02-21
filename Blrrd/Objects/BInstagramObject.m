//
//  BInstagramObject.m
//  Blrrd
//
//  Created by Joe Barbour on 18/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import "BInstagramObject.h"
#import "BConstants.h"

@implementation BInstagramObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.credentials = [[BCredentialsObject alloc] init];
        self.mixpanel = [Mixpanel sharedInstance];
        
    }
    return self;
    
}

-(void)queryInstagramProfile:(void (^)(NSDictionary *profile))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/?access_token=%@" ,self.credentials.instagramToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"];
        if (output != nil) completion(output);
        else completion(nil);
        
    }];
    
    [task resume];
    
}

-(void)queryFrendshipStatus:(NSString *)user completion:(void (^)(BOOL connected))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship?access_token=%@" ,user ,self.credentials.instagramToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data.length > 0) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"];
            if ([[output objectForKey:@"outgoing_status"] isEqualToString:@"follows"]) completion(true);
            else completion(false);
            
        }
        
    }];
    
    [task resume];

}

-(void)queryFriends:(void (^)(NSArray *contacts))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@" ,self.credentials.instagramToken]];
    NSLog(@"instaurl: %@" ,url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data.length > 0) {
            completion([[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"]);

        }
        
    }];
    
    [task resume];
    
}

-(void)queryInstagramIdentifyer:(NSString *)search completion:(void (^)(NSString *identifyer ,NSError *error))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&access_token=%@" ,search ,self.credentials.instagramToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
    [request setHTTPMethod:@"GET"];

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data.length > 0 && error == nil) {
            NSDictionary *output = [[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"] firstObject];
            if (output != nil) completion([output objectForKey:@"id"],  [NSError errorWithDomain:@"results found" code:200 userInfo:nil]);
            else completion(@"", [NSError errorWithDomain:@"no results" code:2 userInfo:nil]);
            
        }
        else completion(@"", error);
        
    }];
    
    [task resume];
    
}

-(void)updateFriendship:(NSString *)user action:(NSString *)action completion:(void (^)(NSError *error))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship?access_token=%@", user ,self.credentials.instagramToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
    
    [request setHTTPBody:[[NSString stringWithFormat:@"action=%@", action] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    [request setHTTPMethod:@"POST"];

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data.length > 0) {
            NSLog(@"INSTAGRAM DATA: %@" ,[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            
        }
        
    }];
    
    [task resume];
    
}

-(NSURLSession *)requestSession:(BOOL)main {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.qualityOfService = main?NSQualityOfServiceUtility:NSQualityOfServiceBackground;
    
    return [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:queue];
    
}


@end
