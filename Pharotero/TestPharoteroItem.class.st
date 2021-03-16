Class {
	#name : #TestPharoteroItem,
	#superclass : #TestCase,
	#category : #'Pharotero-tests'
}

{ #category : #tests }
TestPharoteroItem >> testFromJSON [
	| jsonString pharoteroItem |
	jsonString := '{
	"key": "ABCD1234",
	"itemType": "document",
	"title": "Something about nothing",
	"creators": [
		{
			"creatorType": "author",
			"firstName": "John",
			"lastName": "Doe"
		},
		{
			"creatorType": "author",
			"firstName": "Jane",
			"lastName": "Doe"
		}],
	"abstractNote": "Nothing happened and this is all good and well",
	"date": "2021-03-10",
	"collections": [ "9876WXYZ", "5432LMNO"]
}'.

	pharoteroItem := (NeoJSONReader on: jsonString readStream) nextAs: PharoteroItem.
	
	self assert: pharoteroItem key 				 equals: 'ABCD1234'.
	self assert: pharoteroItem itemType 			 equals: 'document'.
	self assert: pharoteroItem authors size 	 equals: 2.
	self assert: pharoteroItem title 				 equals: 'Something about nothing'.
	self assert: pharoteroItem abstract 			 equals: 'Nothing happened and this is all good and well'.
	self assert: pharoteroItem date 				 equals: '2021-03-10'.
	self assert: pharoteroItem parentCollection equals: '9876WXYZ'.
]

{ #category : #tests }
TestPharoteroItem >> testToJSON [
	| pharoteroItem |
	pharoteroItem := PharoteroItem new 
		key: 'ABCD1234' ;
		itemType: 'document' ;
		authors: { PharoteroAuthor firstName: 'John' lastName: 'Doe' } ;
		title: 'Something about nothing' ;
		abstract: 'Nothing happened and this is all good and well' ;
		date: '2021-03-10' ;
		parentCollection: '9876WXYZ' ;
		yourself.
		
	self assert: ((NeoJSONWriter toString: pharoteroItem)
		includesSubstring: '"key":"ABCD1234"').
	self assert: ((NeoJSONWriter toString: pharoteroItem)
		includesSubstring: '"itemType":"document"').
	self assert: ((NeoJSONWriter toString: pharoteroItem)
		includesSubstring: '"creators":[{"creatorType":"author","firstName":"John","lastName":"Doe"}]').
	self assert: ((NeoJSONWriter toString: pharoteroItem)
		includesSubstring: '"title":"Something about nothing"').
	self assert: ((NeoJSONWriter toString: pharoteroItem)
		includesSubstring: '"abstractNote":"Nothing happened and this is all good and well"').
	self assert: ((NeoJSONWriter toString: pharoteroItem)
		includesSubstring: '"date":"2021-03-10"').
	self assert: ((NeoJSONWriter toString: pharoteroItem)
		includesSubstring: '"collections":["9876WXYZ"]').

]
