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

#import "Note.h"

@implementation Note
@synthesize noteContent;

- (id)init
{
  self = [super init];
  if (self)
  {
    
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError **)outError
{
  
  if ([contents length] > 0) {
    self.noteContent = [[NSString alloc]
                        initWithBytes:[contents bytes]
                        length:[contents length]
                        encoding:NSUTF8StringEncoding];
  } else {
    // When the note is first created, assign some default content
    self.noteContent = @"Empty";
  }
  
  return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
  
  if ([self.noteContent length] == 0) {
    self.noteContent = @"Empty";
  }
  
  return [NSData dataWithBytes:[self.noteContent UTF8String]
                        length:[self.noteContent length]];
  
}


@end
