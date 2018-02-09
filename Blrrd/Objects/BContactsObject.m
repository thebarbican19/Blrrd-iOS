//
//  BContactsObject.m
//  Blrrd
//
//  Created by Joe Barbour on 05/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import "BContactsObject.h"
#import "BConstants.h"

@implementation BContactsObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.credentials = [[BCredentialsObject alloc] init];
        self.query = [[BQueryObject alloc] init];
        self.mixpanel = [Mixpanel sharedInstance];
        self.store = [[CNContactStore alloc] init];
        self.user = [[NSMutableDictionary alloc] init];
        self.appdel = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.qualityOfService = NSQualityOfServiceBackground;
        
    }
    return self;
    
}

-(void)contactsGrantAccess:(void (^)(bool granted, NSError *error))completion {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        completion(true, nil);
        
    }
    else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            completion(granted, error);
            
        }];
        
    }
    else {
        completion(false, [NSError errorWithDomain:@"not authorized" code:403 userInfo:nil]);
        
    }
    
}

-(NSArray *)contactRequestKeys {
    return @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
             CNContactEmailAddressesKey,
             CNContactPhoneNumbersKey,
             CNContactThumbnailImageDataKey,
             CNContactOrganizationNameKey,
             CNContactPostalAddressesKey,
             CNContactBirthdayKey,
             CNContactSocialProfilesKey];
    
}

-(void)contactsReturn:(BOOL)sections completion:(void (^)(NSArray *contacts, int count))completion {
    self.contacts = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [self.store containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers:@[self.store.defaultContainerIdentifier]] error:nil];
        [self.store enumerateContactsWithFetchRequest:[[CNContactFetchRequest alloc] initWithKeysToFetch:[self contactRequestKeys]] error:nil usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop){
            [self.contacts addObject:@{@"contact_id":contact.identifier,
                                       @"contact_name":[self contactsFormatName:contact],
                                       @"contact_email":[self contactsFormatEmail:contact],
                                       @"contact_phone":[self contactsFormatPhone:contact],
                                       @"contact_socials":[self contactsFormatSocialHandles:contact],
                                       @"contact_thumbnail":contact.thumbnailImageData==nil?[NSData data]:contact.thumbnailImageData}];
            
            
        }];
        
        if (sections) completion([self contactsSections:self.contacts], (int)[self.contacts count]);
        else completion(self.contacts, (int)[self.contacts count]);
        
        if (self.credentials.appContactsUpdateExpired) {
            [self contactsParseUserData:true completion:nil];

        }
        
    });
    
}

-(void)contactsParseUserData:(BOOL)background completion:(void (^)(NSDictionary *data))completion {
    dispatch_async(dispatch_get_global_queue(background?QOS_CLASS_USER_INITIATED:DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address contains %@" ,self.credentials.userEmail];
        
        [self.store containersMatchingPredicate:[CNContainer predicateForContainersWithIdentifiers:@[self.store.defaultContainerIdentifier]] error:nil];
        [self.store enumerateContactsWithFetchRequest:[[CNContactFetchRequest alloc] initWithKeysToFetch:[self contactRequestKeys]] error:nil usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop) {
            if ([[[self contactsFormatEmail:contact] filteredArrayUsingPredicate:predicate] count] > 0) {
                [self.user setObject:[self contactsFormatName:contact] forKey:@"name"];
                [self.user setObject:contact.identifier forKey:@"key"];
                
                if ([[self contactsFormatPhone:contact] count] > 0) {
                    [self.user setObject:[[self contactsFormatPhone:contact] firstObject] forKey:@"phones"];
                    
                }
                
                if ([[self contactsFormatEmail:contact] count] > 0) {
                    [self.user setObject:[[self contactsFormatEmail:contact] firstObject] forKey:@"emails"];
                    
                }
                
                if ([[contact thumbnailImageData] length] > 0) {
                    [self.user setObject:contact.thumbnailImageData forKey:@"avatar"];
                    
                }
                
                if ([[self contactsFormatSocialHandles:contact] count] > 0) {
                    [self.user setObject:[self contactsFormatSocialHandles:contact] forKey:@"social"];
                    
                }
                
                if (([[self contactsFormatBirthday:contact] compare:[NSDate dateWithTimeIntervalSinceNow:-(60*60*24*500)]]) == NSOrderedAscending) {
                    [self.user setObject:[self contactsFormatBirthday:contact] forKey:@"dob"];
                    
                }
                
                if (!background) completion(self.user);
                
            }
            
        }];
        
        [self contactUpdateCredentials];
        
    });
    
}

-(NSString *)contactsFormatName:(CNContact *)contact {
    NSMutableString *name = [NSMutableString string];
    if (([contact givenName] != nil && ![contact.givenName isEqualToString:@""]) || ([contact familyName] != nil && ![contact.familyName isEqualToString:@""])) {
        if ([contact givenName] != nil && ![contact.givenName isEqualToString:@""]) {
            [name appendString:contact.givenName];
            
        }
        
        if ([name length] > 0) {
            [name appendString:@" "];
            
        }
        
        if ([contact familyName] != nil && ![contact.familyName isEqualToString:@""]) {
            [name appendString:contact.familyName];
            
        }
        
    }
    else [name appendString:contact.organizationName];
    
    return name;
    
}

-(NSDictionary *)contactsFormatLocation:(CNContact *)contact {
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    NSArray *addresses = (NSArray*)[contact.postalAddresses valueForKey:@"value"];
    if (addresses.count > 0) {
        for (CNPostalAddress *address in addresses) {
            if (address.city.length > 0) [location setObject:address.city forKey:@"city"];
            if (address.subLocality.length > 0) [location setObject:address.subLocality forKey:@"city"];
            if (address.country.length > 0) [location setObject:address.country forKey:@"country"];
            
        }
        
    }
    
    return location;
    
}

-(NSDate *)contactsFormatBirthday:(CNContact *)contact {
    if (contact.birthday != nil) return [[[NSCalendar currentCalendar] dateFromComponents:contact.birthday] dateByAddingTimeInterval:3600];
    else return [NSDate date];
    
}

-(NSDictionary *)contactsFormatSocialHandles:(CNContact *)contact {
    NSMutableDictionary *social = [[NSMutableDictionary alloc] init];
    NSArray *networks = (NSArray*)[contact.socialProfiles valueForKey:@"value"];
    if (networks.count > 0) {
        for (CNSocialProfile *handle in networks) {
            if (![handle.service isEqualToString:@"Game Center"]) {
                if (handle.username != nil && handle.service.lowercaseString) {
                    [social setObject:handle.username forKey:handle.service];
                    [self.mixpanel.people set:@{handle.service:handle.username}];
                    
                }
                
            }
            
        }
        
    }
    
    return social;
    
}

-(NSArray *)contactsFormatEmail:(CNContact *)contact {
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    for (CNLabeledValue *email in contact.emailAddresses) {
        NSString *label = [CNLabeledValue localizedStringForLabel:email.label]==nil?@"email":[CNLabeledValue localizedStringForLabel:email.label];
        NSString *formatted = [email valueForKey:@"value"];
        
        [emails addObject:@{@"label":label, @"address":formatted}];
        
    }
    
    return emails;
    
}

-(NSArray *)contactsFormatPhone:(CNContact *)contact {
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for (CNLabeledValue *phone in contact.phoneNumbers) {
        CNPhoneNumber *digits = phone.value;
        NSString *label = [CNLabeledValue localizedStringForLabel:phone.label]==nil?@"phone":[CNLabeledValue localizedStringForLabel:phone.label];
        NSCharacterSet *characters = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
        NSString *number = [[digits.stringValue componentsSeparatedByCharactersInSet:characters] componentsJoinedByString:@""];
        NSLog(@"number %@" ,number);
        [phones addObject:@{@"label":label, @"number":number}];
        
    }
    
    return phones;
    
}

-(NSArray *)contactsSections:(NSArray *)contacts {
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"contact_name" ascending:true];
    NSMutableArray *contactsMerge = [[contacts sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    for (int i = 0; i < contactsMerge.count; i++) {
        if ([[[contactsMerge objectAtIndex:i] objectForKey:@"contact_name"] length] > 0) {
            if (![sections containsObject:[[[[contactsMerge objectAtIndex:i] objectForKey:@"contact_name"] substringToIndex:1] capitalizedString]]) {
                [sections addObject:[[[[contactsMerge objectAtIndex:i] objectForKey:@"contact_name"] substringToIndex:1] capitalizedString]];
                
            }
            
        }
        
    }
    
    for (NSDictionary *person in contacts) {
        if ([[person objectForKey:@"contact_name"] length] > 0) {
            NSString *initial = [[[person objectForKey:@"contact_name"] substringToIndex:1] capitalizedString];
            NSArray *fitered = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_name BEGINSWITH[cd] %@" ,initial]];
            int index = (int)[sections indexOfObject:initial];
            if (index < sections.count) {
                [sections replaceObjectAtIndex:index withObject:@{initial:[fitered sortedArrayUsingDescriptors:@[sort]]}];
                
            }
            
        }
        
    }
    
    return sections;
    
}

-(void)contactUpdateCredentials {
    

    [self.mixpanel track:@"App Parsed Contacts Data"];

    if ([self.credentials userBirthday] == nil && [self.user objectForKey:@"dob"] != nil) {
        [self.credentials setUserBirthday:[self.user objectForKey:@"dob"]];
        [self.queue addOperationWithBlock:^{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
            formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            [self.query postUpdateUser:nil type:@"dob" value:[formatter stringFromDate:self.credentials.userBirthday] completion:^(NSError *error) {
                [self.credentials setAppContactUpdateExpiry:false];
                
            }];
            
        }];
        
    }
    
    
    if ([self.credentials userPhone:false] == nil && [[self.user objectForKey:@"phones"] objectForKey:@"number"] != nil) {
        [self.credentials setUserPhoneNumber:[[self.user objectForKey:@"phones"] objectForKey:@"number"]];
        [self.queue addOperationWithBlock:^{
            [self.query postUpdateUser:nil type:@"phone" value:[self.credentials userPhone:false] completion:^(NSError *error) {
                [self.credentials setAppContactUpdateExpiry:false];
                [self.mixpanel.people set:@{@"$phone":[self.credentials userPhone:false]}];

            }];
            
        }];
        
    }
    
    if ([self.credentials userFullname] == nil && [self.user objectForKey:@"name"] != nil) {
        [self.credentials setUserFullname:[self.user objectForKey:@"name"]];
        [self.queue addOperationWithBlock:^{
            [self.query postUpdateUser:nil type:@"fullname" value:self.credentials.userFullname completion:^(NSError *error) {
                [self.credentials setAppContactUpdateExpiry:false];
                [self.mixpanel.people set:@{@"$name":self.credentials.userFullname}];

            }];
            
        }];
        
    }
    
}

@end
