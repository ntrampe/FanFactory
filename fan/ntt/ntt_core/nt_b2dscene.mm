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

#import "nt_b2dscene.h"

@implementation nt_b2dscene
@synthesize layer = m_layer;


+ (CCScene *) scene
{
	return [[[self alloc] init] autorelease];
}


- (id)init
{
  self = [super init];
  if (self)
  {
    m_layer = [[nt_b2dlayer alloc] init];
    [self addChild:m_layer];
  }
  return self;
}


- (void)dealloc
{
  if (m_layer != nil)
  {
    [m_layer setMenuStatus:NO node:m_layer];
    [m_layer removeAllMenusStartingFromNode:m_layer];
    [m_layer killAllTouchesStartingFromNode:m_layer];
    [m_layer stopAllActions];
    [m_layer unscheduleAllSelectors];
    [m_layer removeAllChildrenWithCleanup:YES];
    [self removeChild:m_layer cleanup:YES];
    [m_layer release];
    m_layer = nil;
  }
  [super dealloc];
}

@end
