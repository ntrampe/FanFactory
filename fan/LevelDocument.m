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

#import "LevelDocument.h"

@implementation LevelDocument


- (id)initWithFileURL:(NSURL *)url
{
  self = [super initWithFileURL:url];
  if (self)
  {
    m_level = [[nt_level alloc] init];
  }
  return self;
}


- (void)dealloc
{
  if (m_level != nil)
  {
    [m_level release];
    m_level = nil;
  }
  [super dealloc];
}


- (nt_level *)level
{
  return m_level;
}


- (NSString *)name
{
  return [[self fileURL] lastPathComponent];
}


- (void)setLevel:(nt_level *)aLevel
{
  if (m_level != nil)
  {
    [m_level release];
    m_level = nil;
  }
  
  m_level = [aLevel retain];
}


- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError **)outError
{
  if (m_level != nil)
  {
    [m_level release];
    m_level = nil;
  }
  
  if ([contents length] > 0)
  {
    m_level = [[nt_level alloc] initWithData:[NSData dataWithBytes:[contents bytes] length:[contents length]]];
  }
  else
  {
    m_level = [[nt_level alloc] init];
  }
  
  return YES;
}


- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
  if (m_level)
    return m_level.data;
  
  return nil;
}


@end
