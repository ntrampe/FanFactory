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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IAP_CONTENT_PROVIDED @"IAP_CONTENT_PROVIDED"
#define IAP_STARTED_CONTENT @"IAP_STARTED_CONTENT"
#define IAP_FINISHED_CONTENT @"IAP_FINISHED_CONTENT"
#define IAP_FINISHED_PRODUCT_REQUEST @"IAP_FINISHED_PRODUCT_REQUEST"

//taken from Ray Wenderlich at http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface nt_iaphelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
  SKProductsRequest * m_productsRequest;
  RequestProductsCompletionHandler m_completionHandler;
  NSSet * m_productIdentifiers;
  NSArray * m_products;
}

- (id)initWithProductIdentifiers:(NSSet *)aProductIdentifiers;
- (void)requestProducts;
- (void)buyProduct:(SKProduct *)aProduct;
- (void)restoreCompletedTransactions;
- (void)provideContentForProductIdentifier:(NSString *)aProductIdentifier;

@end
