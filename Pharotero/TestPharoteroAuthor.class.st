Class {
	#name : #TestPharoteroAuthor,
	#superclass : #TestCase,
	#category : #'Pharotero-tests'
}

{ #category : #tests }
TestPharoteroAuthor >> testCreationFromJSON [
	| jsonString |
	jsonString := '{"creatorType": "author", "firstName": "John", "lastName": "Doe"}'.
	self
		assert: ((NeoJSONReader on: jsonString readStream) nextAs: PharoteroAuthor) firstName
		equals: 'John'.
	self
		assert: ((NeoJSONReader on: jsonString readStream) nextAs: PharoteroAuthor) lastName
		equals: 'Doe'.

]

{ #category : #tests }
TestPharoteroAuthor >> testCreationFromName [
	self assert: (PharoteroAuthor name: 'First and Last') firstName equals: 'First and'.
	self assert: (PharoteroAuthor name: 'First and Last') lastName equals: 'Last'
]

{ #category : #tests }
TestPharoteroAuthor >> testWritingInJSON [
	self
		assert: (NeoJSONWriter toString: (PharoteroAuthor firstName: 'John' lastName: 'Doe'))
		equals: '{"creatorType":"author","firstName":"John","lastName":"Doe"}'.

]
