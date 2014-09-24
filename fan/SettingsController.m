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

#import "SettingsController.h"
#import "config.h"

@interface SettingsController (Private) 

- (void)initController;

@end

@implementation SettingsController

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
  [super dealloc];
}


- (void)initController
{
  //load the data when the app starts
  [self loadData];
  
  //create the standard settings
  settings = [NSUserDefaults  standardUserDefaults];
  //load settings
  [self loadSettings];
}

#pragma mark -
#pragma mark Data Functions


- (void)saveData
{
  //create the appropriate file path
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *gameDataPath = [documentsDirectory stringByAppendingPathComponent:@"settings"];
	
  //create game data and a keyed archiver
	NSMutableData *gameData;
	NSKeyedArchiver *encoder;
	gameData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:gameData];
	
  //encode it
  [encoder encodeBool:self.debugging        forKey:@"debugging"];
  [encoder encodeBool:self.tutorial         forKey:@"tutorial"];
  [encoder encodeBool:self.editingTutorial  forKey:@"editingTutorial"];
	
	[encoder finishEncoding];
  
  //create it
	[gameData writeToFile:gameDataPath atomically:YES];
	[encoder release];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:SETTINGS_UPDATED_NOTIFICATION object:nil userInfo:nil];
}


- (void)loadData
{
  //create the appropriate file path
  NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"settings"];
  
  //if there is a file then decode it. If not, then set empty values and create one
  if ([fileManager fileExistsAtPath:documentPath])
  {
    NSMutableData *gameData;
    NSKeyedUnarchiver *decoder;
    
    gameData = [NSData dataWithContentsOfFile:documentPath];
    
    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:gameData];
    
    self.debugging  =       [decoder decodeBoolForKey:@"debugging"];
    self.tutorial   =       [decoder decodeBoolForKey:@"tutorial"];
    self.editingTutorial =  [decoder decodeBoolForKey:@"editingTutorial"];
    
    [decoder release];
    
  }
  else
  {
    //create new data
    self.debugging = FALSE;
    self.tutorial = TRUE;
    self.editingTutorial = TRUE;
    self.firstTime = TRUE;
  }
  
  [self saveData];
  
}


- (void)resetData
{
  //create the appropriate file path
  NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"settings"];
  
  //if there is a file then remove it and create another one by loading data. If not, display error
  if ([fileManager fileExistsAtPath:documentPath])
  {
    [fileManager removeItemAtPath:documentPath error:NULL];
    [self loadData];
  }
  else
  {
    //no file
  }
}


#pragma mark -
#pragma mark Settings Functions


- (void)saveSettings
{
  //set settings values
  
  [settings synchronize];
}


- (void)loadSettings
{
  //if there isn't a true value for userDefaultsSet then it's the first time creating settings
  if (![settings boolForKey:@"userDefaultsSet"])
  {
		[settings setBool:YES       forKey:@"userDefaultsSet"];
    [self setSettings];
	}
  else
  {
    [self setSettings];
	}
}


- (void)setSettings
{
  //assign values
}


- (void)resetSettings
{ 
  //reset the settings by setting userDefaultsSet to NO and load settings twice to actually set the values
  [settings setBool:NO forKey:@"userDefaultsSet"];
  [self loadSettings];
}


#pragma mark -
#pragma mark Singleton


static SettingsController *sharedSettingsController = nil;


+ (SettingsController *)sharedSettingsController
{ 
	@synchronized(self) 
	{ 
		if (sharedSettingsController == nil) 
		{ 
			sharedSettingsController = [[self alloc] init]; 
		} 
	} 
  
	return sharedSettingsController; 
} 


+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) 
	{ 
		if (sharedSettingsController == nil) 
		{ 
			sharedSettingsController = [super allocWithZone:zone]; 
			return sharedSettingsController; 
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
