/*
 * Copyright (c) 2013 Nicholas Trampe
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

#import "nt_filemanager.h"

@interface nt_filemanager (Private) 

- (void)initController;

@end

@implementation nt_filemanager

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
  
}


+ (NSString *)documentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}


+ (NSString *)bundleDirectory
{
  return [[NSBundle mainBundle] pathForResource:nil ofType:nil];
}


+ (NSString *)documentsPathForFile:(NSString *)aFile ofType:(NSString *)aType
{
  return [[nt_filemanager documentsDirectory] stringByAppendingFormat:@"/%@%@", aFile, (aType != nil ? [NSString stringWithFormat:@".%@", aType] : @"")];
}


+ (NSString *)bundlePathForFile:(NSString *)aFile ofType:(NSString *)aType
{
  return [[NSBundle mainBundle] pathForResource:aFile ofType:aType];
}


+ (BOOL)pathExists:(NSString *)aPath
{
  NSFileManager * fileManager = [NSFileManager defaultManager];
  return [fileManager fileExistsAtPath:aPath];
}


+ (void)removeAllDocumentsFiles
{
  NSFileManager * fileManager = [NSFileManager defaultManager];
  NSArray * files = [fileManager contentsOfDirectoryAtPath:[nt_filemanager documentsDirectory] error:nil];
  
  for (NSString * file in files)
  {
    [fileManager removeItemAtPath:[[nt_filemanager documentsDirectory] stringByAppendingPathComponent:file] error:NULL];
  }
}


#pragma mark -
#pragma mark Singleton


static nt_filemanager *sharednt_filemanager = nil;


+ (nt_filemanager *)filemanager
{ 
	@synchronized(self) 
	{ 
		if (sharednt_filemanager == nil) 
		{ 
			sharednt_filemanager = [[self alloc] init]; 
		} 
	} 
  
	return sharednt_filemanager; 
} 


+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) 
	{ 
		if (sharednt_filemanager == nil) 
		{ 
			sharednt_filemanager = [super allocWithZone:zone]; 
			return sharednt_filemanager; 
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
