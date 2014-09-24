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

#import "nt_claw.h"
#import "nt_player.h"
#import "config.h"

@interface nt_claw (Private)

- (void)moveUp;

@end

@implementation nt_claw

- (id)initWithPlayer:(nt_player *)aPlayer
{
  self = [super initWithFile:@"start_1.png"];
  if (self) 
  {
    m_holdPos = CGPointMake(self.contentSize.width - aPlayer.contentSize.width - 50.5, aPlayer.position.y - self.contentSize.height/2.0f - aPlayer.contentSize.height/2.0f + 133);
    m_dropPos = CGPointMake(m_holdPos.x, m_holdPos.y - 4);
    
    self.position = m_holdPos;
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


- (void)hold
{
  [self stopAllActions];
  CCAction * move = [CCSequence actionOne:[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.2f position:m_holdPos]] two:[CCCallBlock actionWithBlock:^{
    [self setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"start_1.png" rect:CGRectMake(0, 0, 144, 119)]];
  }]];
  [self runAction:move];
}


- (void)drop
{
  [self stopAllActions];
  [self setDisplayFrame:[CCSpriteFrame frameWithTextureFilename:@"start_2.png" rect:CGRectMake(0, 0, 144, 126)]];
  self.position = m_dropPos;
  
  [self scheduleOnce:@selector(moveUp) delay:0.2f];
}


- (void)moveUp
{
  CCAction * move = [CCEaseSineIn actionWithAction:[CCMoveTo actionWithDuration:0.4f position:CGPointMake(self.position.x, STANDARD_SCREEN_WIDTH)]];
  [self runAction:move];
}


@end
