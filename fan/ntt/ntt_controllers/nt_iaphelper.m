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

#import "nt_iaphelper.h"

@implementation nt_iaphelper

- (id)initWithProductIdentifiers:(NSSet *)aProductIdentifiers
{
  self = [super init];
  if (self) 
  {
    m_productIdentifiers = [aProductIdentifiers copy];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  return self;
}


- (void)dealloc
{
  [m_productIdentifiers release];
  [super dealloc];
}


- (void)requestProducts
{
  if (m_productsRequest != nil)
  {
    [m_productsRequest release];
    m_productsRequest = nil;
  }
  
  m_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:m_productIdentifiers];
  m_productsRequest.delegate = self;
  [m_productsRequest start];
}


- (void)buyProduct:(SKProduct *)aProduct
{
  NSLog(@"Buying %@...", aProduct.productIdentifier);
  
  SKPayment * payment = [SKPayment paymentWithProduct:aProduct];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:IAP_STARTED_CONTENT object:nil];
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
  if (m_productsRequest != nil)
  {
    [m_productsRequest release];
    m_productsRequest = nil;
  }
  
  NSArray * skProducts = response.products;
  for (SKProduct * skProduct in skProducts)
  {
    NSLog(@"Found product: %@ %@ %0.2f",
          skProduct.productIdentifier,
          skProduct.localizedTitle,
          skProduct.price.floatValue);
  }
  
  if (m_products != nil)
  {
    [m_products release];
    m_products = nil;
  }
  
  m_products = [skProducts copy];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:IAP_FINISHED_PRODUCT_REQUEST object:nil];
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
  NSLog(@"Failed to load list of products.");
  
  if (m_productsRequest != nil)
  {
    [m_productsRequest release];
    m_productsRequest = nil;
  }
}


#pragma mark SKPaymentTransactionOBserver


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction * transaction in transactions)
  {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
      case SKPaymentTransactionStateRestored:
        [self restoreTransaction:transaction];
      default:
        break;
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:IAP_FINISHED_CONTENT object:nil];
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Restore Completed" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
  [alert show];
  [alert release];
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
  NSLog(@"completeTransaction...");
  
  [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
  NSLog(@"restoreTransaction...");
  
  [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
  NSLog(@"failedTransaction...");
  
  if (transaction.error.code != SKErrorPaymentCancelled)
  {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:transaction.error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
  }
  
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)provideContentForProductIdentifier:(NSString *)aProductIdentifier
{
  //subclass
  
  NSLog(@"nt_iaphelper: Content provided for %@", aProductIdentifier);
  [[NSNotificationCenter defaultCenter] postNotificationName:IAP_CONTENT_PROVIDED object:nil];
}

- (void)restoreCompletedTransactions
{
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


@end
