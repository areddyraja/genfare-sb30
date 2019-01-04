//
//  GetContentService.m
//  CooCooBase
//
//  Created by John Scuteri on 7/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "AFURLResponseSerialization.h"
#import "AFURLConnectionOperation.h"
#import "AFHTTPRequestOperation.h"
#import "ContentDescription.h"
#import "GetContentService.h"
#import "ContentReference.h"
#import "AFNetworking.h"
#import "RuntimeData.h"
#import "Utilities.h"
#import "Content.h"

@implementation GetContentService
{
 }

- (id)initWithListener:(id)listener managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = listener;
        self.managedObjectContext = context;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities apiHost];
}

- (NSString *)uri
{
    //Line below to be changed
    return [NSString stringWithFormat: @"transit-content"];
}

- (NSDictionary *)createRequest
{
    //Line Directly Below for testing
    [self processResponse:nil];
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    // Below hardcoded response added for testing
    
    //Entries
    NSDictionary *map1 = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"http://upload.wikimedia.org/wikipedia/commons/8/80/Kim_Kardashian_at_the_2009_Tribeca_Film_Festival.jpg", @"url", @"1380564816" ,@"last_updated", @"1380564816" ,@"created", nil];
    NSDictionary *map1description = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"en", @"lang", @"Downtown", @"name",@"Chicago near the headquarters office", @"description", @"1380564816" ,@"last_updated", map1, @"image", nil];
    
    NSDictionary *map2 = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"http://upload.wikimedia.org/wikipedia/commons/3/3b/Hilton%2C_Paris_%282007%29.jpg", @"url", @"1380564816" ,@"last_updated", @"1380564816" ,@"created", nil];
    
    NSDictionary *map2description = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"en", @"lang", @"The Second example to give more body and show an example of more text", @"description", @"Number 2", @"name", @"1380564816" ,@"last_updated", map2, @"image", nil];
    
    //General stuff
    NSArray *maps = [[NSArray alloc] initWithObjects:map1description, map2description, nil];
    NSDictionary *mapsDict = [NSDictionary dictionaryWithObjectsAndKeys:maps, @"genfare", nil];
    json = [NSDictionary dictionaryWithObjectsAndKeys:mapsDict, @"result", @"success", @"status", @"true", @"success", nil];
    
    
    /* Removed for testing
    if ([BaseService isResponseOk:json]) {
    */
    // Added for testing
    if (YES) {
        [self setDataWithJson:[json valueForKey:@"result"]];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSMutableArray *contents = [json valueForKey:[Utilities transitId]];
    if (contents != nil) {
        //Create Directory
        NSError *error = nil;
        NSString *directoryPath= [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[Utilities transitId]];
        if([[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            //Directory Created (Wasn't there before)
            NSLog(@"\n\nDirectory Created\n\n");
            for (NSDictionary *content in contents) {
                [self makeNewContentDescriptionFromDictionary:content];
            }
        } else {
            NSLog(@"\n\nDirectory Already there\n\n");
            for (NSDictionary *content in contents) {
                error = nil;
                NSPredicate *idNumberPredicate = [NSPredicate predicateWithFormat:@"idNum == %@",[content objectForKey:@"id"]];
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:CONTENT_DESCRIPTION_MODEL];
                [fetchRequest setPredicate:idNumberPredicate];
                NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                if(error == nil) {
                    if(result.count == 0) {
                        //Record not there
                        [self makeNewContentDescriptionFromDictionary: content];
                    } else {
                        //Record there check if old
                        NSPredicate *lastUpdatedPredicate = [NSPredicate predicateWithFormat:@"lastUpdated == %@", [content objectForKey:@"last_updated"]];
                        NSPredicate *completePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:idNumberPredicate, lastUpdatedPredicate, nil]];
                        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:CONTENT_DESCRIPTION_MODEL];
                        [fetchRequest setPredicate:completePredicate];
                        NSArray *newResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                        if(error == nil) {
                            if(newResult.count == 0) {
                                //Record has changed
                                //Test Content Reference
                                NSPredicate *cDescriptionPredicate = [NSPredicate predicateWithFormat:@"contentDescriptionIDNum == %@",[content objectForKey:@"id"]];
                                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:CONTENT_REFERENCE_MODEL];
                                [fetchRequest setPredicate:cDescriptionPredicate];
                                newResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                                NSDictionary *consumableContent = [content objectForKey:@"image"];
                                if (((ContentReference *) newResult[0]).contentIDNum != [consumableContent objectForKey:@"id"]){
                                    //Delete the reference
                                    [self.managedObjectContext deleteObject:((ContentReference *) newResult[0])];
                                    //Delete Content
                                    [self safeDeleteContent:((NSNumber *) [consumableContent objectForKey:@"id"])];
                                    //Delete the description
                                    [self.managedObjectContext deleteObject:((ContentDescription *) result[0])];
                                    //Add new entries
                                    [self makeNewContentDescriptionFromDictionary:content];
                                }
                            } else {
                                NSLog(@"Record is unchanged");
                            }
                        }
                    }
                }
            }
            NSLog(@"Done with test");
        }
    }
}
- (void)makeNewContentDescriptionFromDictionary:(NSDictionary *)cDDict
{
    //Create Content Reference
    NSLog(@"Creating Content Reference");
    ContentDescription *contentDescription = (ContentDescription *)[NSEntityDescription insertNewObjectForEntityForName:CONTENT_DESCRIPTION_MODEL inManagedObjectContext:self.managedObjectContext];
    NSError *error;
    [contentDescription setIdNum:[NSNumber numberWithLong:[[cDDict objectForKey:@"id"] integerValue]]];
    [contentDescription setName:[cDDict objectForKey:@"name"]];
    [contentDescription setCDescription:[cDDict objectForKey:@"description"]];
    [contentDescription setLanguage:[cDDict objectForKey:@"lang"]];
    [contentDescription setLastUpdated:[NSNumber numberWithLong:[[cDDict objectForKey:@"last_updated"] integerValue]]];
    [contentDescription setTransitName:[Utilities transitId]];
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    } else {
        NSLog(@"Content Description added");
    }
    //Create for lower levels
    NSArray *types = [NSArray arrayWithObjects: @"image", nil];
    for (NSString *type in types)
    {
        NSDictionary *contentDictionary = [cDDict objectForKey:type];
        if (contentDictionary != nil) {
            //Test Content Reference
            NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"contentIDNum == %@", [contentDictionary objectForKey:@"id"]];
            NSPredicate *cDescriptionPredicate = [NSPredicate predicateWithFormat:@"contentDescriptionIDNum == %@", contentDescription.idNum];
            NSPredicate *completePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:contentPredicate, cDescriptionPredicate, nil]];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:CONTENT_REFERENCE_MODEL];
            [fetchRequest setPredicate:completePredicate];
            NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if(error == nil) {
                if(result.count == 0) {
                    //Make Content Reference
                    ContentReference *contentReference = (ContentReference *)[NSEntityDescription insertNewObjectForEntityForName:CONTENT_REFERENCE_MODEL inManagedObjectContext:self.managedObjectContext];
                    [contentReference setContentDescriptionIDNum:contentDescription.idNum];
                    [contentReference setContentIDNum:[NSNumber numberWithLong:[[contentDictionary objectForKey:@"id"] integerValue]]];
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
                    } else {
                        NSLog(@"Content Reference added");
                    }
                    //Test for existance of content
                    [self testForContent:contentDictionary withType:type];
                } else {
                    //Contenet Reference Exists, test for content
                    [self testForContent:contentDictionary withType:type];
                }
            }
        }
    }
}

- (void)testForContent:(NSDictionary *)contentDict withType:(NSString *)type
{
    NSError *error;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:CONTENT_MODEL];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"idNum == %@", [contentDict objectForKey:@"id"]]];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error == nil) {
        if(result.count == 0) {
            [self makeNewContentFromDictionary: contentDict withType:type];
            NSLog(@"Making Content Here");
        } else if(((Content *) result[0]).idNum == [NSNumber numberWithLong:(long)[contentDict objectForKey:@"id"]]){
            if(((Content *) result[0]).lastUpdated > [NSNumber numberWithLong:(long)[contentDict objectForKey:@"last_updated"]]) {
                [self deleteOldContent:result[0]];
                [self makeNewContentFromDictionary:contentDict withType:type];
            } else {
                NSLog(@"Record not updated as it has not changed");
            }
        }
    }

}

- (void)makeNewContentFromDictionary:(NSDictionary *)contDict withType:(NSString *)type
{
    NSLog(@"SUCCESS");
    //Download and set
    NSString *directoryPath= [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[Utilities transitId]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",directoryPath ,[contDict objectForKey:@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[contDict objectForKey:@"url"]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
        //Create Map Object
        NSError *error;
        Content *content = (Content *)[NSEntityDescription insertNewObjectForEntityForName:CONTENT_MODEL inManagedObjectContext:self.managedObjectContext];
        [content setUrl:filePath];
        [content setIsLocal:[NSNumber numberWithBool:YES]];
        [content setIdNum:[NSNumber numberWithLong:[[contDict objectForKey:@"id"] integerValue]]];
        [content setLastUpdated:[NSNumber numberWithLong:[[contDict objectForKey:@"last_updated"] integerValue]]];
        [content setType:type];
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        } else {
            NSLog(@"Content added");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"\n\nFAILURE\n\n");
    }];
    [operation start];
}

- (void)deleteOldContent:(Content *)cont
{
    //Delete map file
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cont.url])		//Does file exist?
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:cont.url error:&error])	//Delete it
        {
            NSLog(@"Delete file error: %@", error);
        } else {
            NSLog(@"Deleted File");
        }
    }
    //Delete content object
    [self.managedObjectContext deleteObject:cont];
}
- (void)safeDeleteContent:(NSNumber *)contentNumber
{
    //Test if content has any other references to it
    //Test Content Reference
    NSError *error;
    NSPredicate *contentReferencePredicate = [NSPredicate predicateWithFormat:@"contentIDNum == %@", contentNumber];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:CONTENT_REFERENCE_MODEL];
    [fetchRequest setPredicate:contentReferencePredicate];
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error == nil) {
        //Below Test if there are any remaining references to the selected content
        if(result.count == 0) {
            //Find Content to delete as there is no references to the content
            NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"idNum == %@", contentNumber];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:CONTENT_MODEL];
            [fetchRequest setPredicate:contentPredicate];
            NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if(error == nil) {
                if(result.count > 0) {
                    [self deleteOldContent:((Content *) result[0])];
                }
            }
        }
    }
}

@end
