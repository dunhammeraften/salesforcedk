@IsTest(IsParallel = true)
public with sharing class StackTest {
    @IsTest
	static void givenStackWithItems_whenPopIsCalled_returnsLastPushedItem() {
        //ARRANGE
        Stack s = new Stack();
        s.push('item_one');
        s.push('item_two');

        //ACT
        String myLatestItem = (String) s.pop();

        //ASSERT
        Assert.isTrue(myLatestItem == 'item_two');
    }

    @IsTest
	static void givenStackWithItems_whenSizeIsCalled_returnsNumberOfItems() {
        //ARRANGE
        Stack s = new Stack();

        s.push('item_one');
        s.push('item_two');
        s.push('item_three');
        s.pop();
        s.push('item_four');

        //ACT
        Integer numberOfItems =  s.size();
        //ASSERT
        Assert.isTrue(numberOfItems == 3, 'We have three items since item_three was poped!');
    }

    @IsTest
	static void givenStackWithoutItems_whenPopIsCalled_throwStackUnderflowException() {
        //ARRANGE
        Stack s = new Stack();
        Boolean stackUnderflowExceptionWasThrown = false;

        //ACT
        try{
            String myLatestItem = (String) s.pop();
        }catch(StackUnderflowException exp){
            stackUnderflowExceptionWasThrown = true;
        }

        //ASSERT
        Assert.isTrue(stackUnderflowExceptionWasThrown, 'The stack thrown an underflowexception');
    }

    @IsTest
    static void givenStackWithoutItems_whenIsEmptyIsCalled_returnsTrue(){
        //ARRANGE
        Stack s = new Stack();

        //ACT
        Boolean isEmpty = s.isEmpty();

        //ASSERT
        Assert.isTrue(isEmpty, 'IsEmpty() returns true when it contains 0 items');
    }

    @IsTest
    static void givenStackWithItems_whenIsEmptyIsCalled_returnsFalse(){
        //ARRANGE
        Stack s = new Stack();
        s.push('item_one');

        //ACT
        Boolean isEmpty = s.isEmpty();
        
        //ASSERT
        Assert.isFalse(isEmpty, 'IsEmpty() returns false when it contains 0 items');
    }
}