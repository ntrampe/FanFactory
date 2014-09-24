//
//  nt_coin.h
//  fan
//
//  Created by Nick Trampe on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "nt_object.h"

@interface nt_coin : nt_object <NSCopying>
{
  BOOL m_eaten;
}
@property (nonatomic, readonly) BOOL isEaten;

- (BOOL)eatMe;

@end