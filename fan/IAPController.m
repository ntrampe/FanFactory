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

#import "IAPController.h"
#import "PackController.h"
#import "config.h"

@interface IAPController (Private)

- (void)initController;

@end

@implementation IAPController

#pragma mark -
#pragma mark Init


- (id)initWithProductIdentifiers:(NSSet *)aProductIdentifiers
{
  self = [super initWithProductIdentifiers:aProductIdentifiers];
  if (self)
  {
    [self initController];
  }
  
  return self;
}

- (void)dealloc
{
  if (m_products != nil)
  {
    [m_products release];
    m_products = nil;
  }
  [super dealloc];
}


- (void)initController
{
  sharedPC = [PackController sharedPackController];
  
}


- (void)makePaymentForCoins:(unsigned int)aCoins
{
  if (m_products != nil)
  {
    for (SKProduct * p in m_products)
    {
      if ([p.productIdentifier hasSuffix:[NSString stringWithFormat:@"coins%i", aCoins]])
      {
        [self buyProduct:p];
      }
    }
  }
}


- (void)provideContentForProductIdentifier:(NSString *)aProductIdentifier
{
  [super provideContentForProductIdentifier:aProductIdentifier];
  
  int coins = [[aProductIdentifier stringByReplacingOccurrencesOfString:@"com.offkilterstudios.fan.coins" withString:@""] intValue];
  
  if (coins != 0)
  {
    sharedPC.coins += coins;
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%i coins received!", coins] message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [sharedPC saveData];
  }
}


#pragma mark -
#pragma mark Singleton


static IAPController *sharedIAPController = nil;


+ (IAPController *)sharedIAPController
{ 
	@synchronized(self) 
	{ 
		if (sharedIAPController == nil) 
		{
      NSSet * productIdentifiers = [NSSet setWithObjects:
                                    @"com.offkilterstudios.fan.coins100",
                                    @"com.offkilterstudios.fan.coins300",
                                    @"com.offkilterstudios.fan.coins500",
                                    nil];
			sharedIAPController = [[self alloc] initWithProductIdentifiers:productIdentifiers];
		} 
	} 
  
	return sharedIAPController; 
} 


+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) 
	{ 
		if (sharedIAPController == nil) 
		{ 
			sharedIAPController = [super allocWithZone:zone]; 
			return sharedIAPController; 
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
