//
//  BContactsObject.h
//  Blrrd
//
//  Created by Joe Barbour on 05/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ContactsUI/ContactsUI.h>
#import <Mixpanel.h>

#import "BCredentialsObject.h"
#import "BQueryObject.h"
#import "AppDelegate.h"

@interface BContactsObject : NSObject

@property (nonatomic, strong) CNContactStore *store;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableDictionary *user;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic, retain) AppDelegate *appdel;
@property (nonatomic, retain) BCredentialsObject *credentials;
@property (nonatomic, retain) BQueryObject *query;

-(BOOL)contactsAuthorized;
-(void)contactsGrantAccess:(void (^)(bool granted, NSError *error))completion;
-(void)contactsReturn:(BOOL)sections completion:(void (^)(NSArray *contacts, int count))completion;
-(NSArray *)contactsSections:(NSArray *)contacts;
-(void)contactsParseUserData:(BOOL)background completion:(void (^)(NSDictionary *data))completion;

@end

