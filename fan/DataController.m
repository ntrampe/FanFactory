/*
 * Copyright (c) 2014 Nicholas Trampe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

#import "DataController.h"
#import "config.h"
#import "LevelDocument.h"

@interface DataController (Private) 

- (void)initController;

@end

@implementation DataController

#pragma mark -
#pragma mark Init


- (id)init
{
  self = [super init];
  if (self)
  {
    [self initController];
  }
  
  return self;
}


- (void)dealloc
{
  [m_levels release];
  [super dealloc];
}


- (void)initController
{
  m_levels = [[NSMutableArray alloc] init];
  
  m_query = [[NSMetadataQuery alloc] init];
  [m_query setSearchScopes:
   [NSArray arrayWithObject:
    NSMetadataQueryUbiquitousDocumentsScope]];
  NSPredicate * predicate = [NSPredicate predicateWithFormat:
                             @"%K like '*.dat'", NSMetadataItemFSNameKey];
  
  [m_query setPredicate:predicate];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(loadLevelsFromCloudDirectory)
                                               name:NSMetadataQueryDidUpdateNotification
                                             object:m_query];
}


- (NSURL *)cloudURL
{
  return [[NSFileManager defaultManager]
          URLForUbiquityContainerIdentifier:nil];
}


- (NSURL *)cloudDocumentsURLForFileName:(NSString *)aFileName
{
  return [[self.cloudURL URLByAppendingPathComponent:@"Documents"]
          URLByAppendingPathComponent:aFileName];
}


- (BOOL)hasCloudAccess
{
  return [self cloudURL];
}


- (void)loadLevelsFromCloudDirectory
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(queryDidFinishGathering:)
                                               name:NSMetadataQueryDidFinishGatheringNotification
                                             object:nil];
  
  [m_query enableUpdates];
  [m_query startQuery];
}


- (void)queryDidFinishGathering:(NSNotification *)notification
{
  [self loadData];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSMetadataQueryDidFinishGatheringNotification
                                                object:nil];
  
  [m_query disableUpdates];
  [m_query stopQuery];
  
  NSLog(@"DataController - Finished Gathering");
}


- (void)loadData
{
  [m_levels removeAllObjects];
  
  for (NSMetadataItem *item in [m_query results])
  {
    NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
    LevelDocument *doc = [[LevelDocument alloc] initWithFileURL:url];
    
    [m_levels addObject:doc];
    
    [doc release];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:CLOUD_UPDATED_NOTIFICATION object:nil];
}


- (NSMutableArray *)levels
{
  return m_levels;
}


- (void)addLevelWithName:(NSString *)aName
{
  [self addLevelWithName:aName andLevel:NULL];
}


- (void)addLevelWithName:(NSString *)aName andLevel:(nt_level *)aLevel
{
  LevelDocument * doc = [[LevelDocument alloc] initWithFileURL:[self cloudDocumentsURLForFileName:aName]];
  
  if (aLevel != NULL)
  {
    [doc setLevel:aLevel];
  }
  
  [doc saveToURL:[doc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){}];
  [m_levels addObject:doc];
  [doc release];
}


- (void)removeLevelWithName:(NSString *)aName
{
  LevelDocument * doc = nil;
  
  for (LevelDocument * d in m_levels)
  {
    if ([d.name isEqualToString:aName])
    {
      doc = d;
    }
  }
  
  if (doc != nil)
  {
    NSURL * fileURL = [doc fileURL];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
      NSFileManager* fileManager = [NSFileManager defaultManager];
      [fileManager removeItemAtURL:fileURL error:nil];
    });
    
    [m_levels removeObject:doc];
  }
}


#pragma mark -
#pragma mark Singleton


static DataController *sharedDataController = nil;


+ (DataController *)sharedDataController
{ 
	@synchronized(self) 
	{ 
		if (sharedDataController == nil) 
		{ 
			sharedDataController = [[self alloc] init]; 
		} 
	} 
  
	return sharedDataController; 
} 


+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) 
	{ 
		if (sharedDataController == nil) 
		{ 
			sharedDataController = [super allocWithZone:zone]; 
			return sharedDataController; 
		} 
	} 
  
	return nil; 
} 


- (id)copyWithZone:(NSZone *)zone 
{ 
	return self; 
} 


- (id)retain 
{ 
	return self; 
} 


- (NSUInteger)retainCount 
{ 
	return NSUIntegerMax; 
} 


- (id)autorelease 
{ 
	return self; 
}


@end
