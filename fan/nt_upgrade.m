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

#import "nt_upgrade.h"
#import "PackController.h"

@implementation nt_upgrade
@synthesize title = m_title, info = m_info, preview = m_preview;
@synthesize level = m_level;

- (id)initWithTitle:(NSString *)aTitle info:(NSString *)aInfo preview:(NSString *)aPreview level:(unsigned int)aLevel
{
  self = [super init];
  if (self)
  {
    sharedPC = [PackController sharedPackController];
    
    m_title = [aTitle copy];
    m_info = [aInfo copy];
    m_preview = [aPreview copy];
    m_level = aLevel;
  }
  return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  NSString * title    = [aDecoder decodeObjectForKey:@"title"];
  NSString * info    = [aDecoder decodeObjectForKey:@"info"];
  NSString * preview = [aDecoder decodeObjectForKey:@"preview"];
  unsigned int level  = [aDecoder decodeIntForKey:@"level"];
  
  return [self initWithTitle:title info:info preview:preview level:level];
}


- (void)dealloc
{
  [m_title release];
  [m_info release];
  [m_preview release];
  [super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:m_title forKey:@"title"];
  [aCoder encodeObject:m_info forKey:@"info"];
  [aCoder encodeObject:m_preview forKey:@"preview"];
  [aCoder encodeInt:m_level forKey:@"level"];
}


- (BOOL)upgrade
{
  if ([self canAffordToUpgrade])
  { 
    sharedPC.coins -= [self currentPrice];
    [sharedPC saveData];
    
    m_level++;
    
    if (m_level > self.maxLevel)
      m_level = self.maxLevel;
    
    [self setLocalValues];
    
    return TRUE;
  }
  return FALSE;
}


- (void)setLocalValues
{
  //override
}


- (unsigned int)priceForLevel:(int)aLevel
{
  return 0;
}


- (unsigned int)currentPrice
{
  return [self priceForLevel:m_level+1];
}


- (double)valueForLevel:(int)aLevel
{
  return 0;
}


- (double)currentValue
{
  return [self valueForLevel:m_level];
}


- (BOOL)canAffordToUpgrade
{
  return (sharedPC.coins >= self.currentPrice);
}


- (int)maxLevel
{
  return 5;
}


- (BOOL)isMaxed
{
  return (m_level == self.maxLevel);
}


@end
