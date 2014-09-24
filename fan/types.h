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

typedef enum
{
  kBlockTypeLongSmall = 0,
  kBlockTypeLongLarge = 1,
  kBlockTypeSquareSmall = 2,
  kBlockTypeSquareLarge = 3,
  kBlockTypeTriangleHole = 4,
  kBlockTypeTriangleWhole = 5,
  kBlockTypeCircle = 6
}kBlockType;


typedef enum
{
  kObjectMovementTypeNone = 0,
  kObjectMovementTypeOscillateVertical = 1,
  kObjectMovementTypeOscillateHorizontal = 2,
  kObjectMovementTypeRotate = 3,
}kObjectMovementType;


typedef struct
{
  BOOL snaps, guide, invert;
  kObjectMovementType movement;
  float time;
}kObjectAttributes;


enum kTag
{
  kTagPlayer = 7,
  kTagFan = 8,
  kTagWind = 9,
  kTagBlock = 10,
  kTagGround = 11,
  kTagFinish = 12,
  kTagPoof = 13,
  kTagLevelEdit = 14,
  kTagTrashCan = 15,
  kTagCoin = 16
};


typedef enum
{
  kGameStateRunning = 0,
  kGameStatePaused = 1,
  kGameStateEditing = 2,
  kGameStateOver = 3
}kGameState;

