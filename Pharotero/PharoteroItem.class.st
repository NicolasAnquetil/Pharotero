"
I represents a reference in a Zotero (http://www.zotero.org) library.


"
Class {
	#name : #PharoteroItem,
	#superclass : #Object,
	#instVars : [
		'key',
		'parentCollection',
		'itemType',
		'title',
		'authors',
		'abstract',
		'date',
		'url',
		'publisher',
		'comment'
	],
	#category : #'Pharotero-entities'
}

{ #category : #'instance creation' }
PharoteroItem class >> listFromJSON: jsonString [
	"parsing JSON for Zotero items is a bit tricky as we are only interested in the #data filed of the JSON
	 So we use a virtual object #TransferObject that gets the PharoteroItem into a #data instance variable and then we collect these PharoteroItems"
	^((NeoJSONReader on: jsonString readStream)
	for: #TransferObject do: [ :mapping |
        mapping subjectClass: NeoJSONObject.
        (mapping mapAccessor: #data) valueSchema: PharoteroItem ] ;
	nextListAs: #TransferObject )
	reject: [ :i | i itemType = 'note' ] thenCollect: #data.

]

{ #category : #accessing }
PharoteroItem class >> neoJsonMapping: mapper [
	"mapping from the #data field of a JSON Zotero item to a PharoteroItem
	instance variables #key, #itemType, #title, #url, #publisher are mapped directly to correponding JSON fields
	instance variable #abstract is mapped to JSON field #abstractNote
	instance variable #comment is mapped to JSON field #extra
	instance variable #authors is mapped to JSON field #creators (a list of PharoteroAuthor)
	instance variable #collection (not appearing here) is mapped to JSON field #collections through specialized 'accessors' #jsonCollection"
	mapper
		for: PharoteroItem do: [ :mapping | 
	      mapping mapInstVars: #(key itemType title url publisher date).
			mapping mapInstVar: #abstract to: #abstractNote.
			mapping mapInstVar: #comment to: #extra.
			(mapping mapInstVar: #authors to: #creators)
				valueSchema: #listOfCreators.
			mapping mapAccessor: #jsonCollection to: #collections
		] ;
		for: #listOfCreators customDo: [ :mapping |
			mapping listOfElementSchema: PharoteroAuthor .
		]
]

{ #category : #accessing }
PharoteroItem >> abstract [
	^ abstract
]

{ #category : #accessing }
PharoteroItem >> abstract: aString [
	abstract := aString
]

{ #category : #accessing }
PharoteroItem >> authors [
	^ authors
]

{ #category : #accessing }
PharoteroItem >> authors: aList [
	authors := aList
]

{ #category : #accessing }
PharoteroItem >> comment [
	^ comment
]

{ #category : #accessing }
PharoteroItem >> comment: anObject [
	comment := anObject
]

{ #category : #copying }
PharoteroItem >> copyFrom: anotherItem [
	abstract := anotherItem abstract.
	authors := anotherItem authors.
	comment := anotherItem comment.
	date := anotherItem date.
	itemType := anotherItem itemType.
	key := anotherItem key.
	parentCollection := anotherItem  parentCollection.
	publisher := anotherItem publisher.
	title := anotherItem title.
	url := anotherItem url.
	
]

{ #category : #accessing }
PharoteroItem >> date [
	^ date
]

{ #category : #accessing }
PharoteroItem >> date: aString [
	date := aString
]

{ #category : #accessing }
PharoteroItem >> itemType [
	^ itemType
]

{ #category : #accessing }
PharoteroItem >> itemType: aString [
	itemType := aString 
]

{ #category : #accessing }
PharoteroItem >> jsonCollection [
	"must return an array of collection keys (strings)"
	^self parentCollectionKey
		ifNil: [ #() ]
		ifNotNil: [ :aString | { aString } ]
]

{ #category : #accessing }
PharoteroItem >> jsonCollection: jsonCollections [
	"#jsonCollections is an array of collecxtion keys (strings)
	#parentCollection can be a string or a PharoteroCollection"
	jsonCollections
		ifEmpty: [ ^self ].
	(self parentCollectionKey = jsonCollections first)
		ifTrue: [ ^self ].
	self parentCollection: jsonCollections first

]

{ #category : #accessing }
PharoteroItem >> key [
	^ key
]

{ #category : #accessing }
PharoteroItem >> key: aString [
	key := aString 
]

{ #category : #accessing }
PharoteroItem >> parentCollection [
	^ parentCollection
]

{ #category : #accessing }
PharoteroItem >> parentCollection: aString [
	parentCollection := aString
]

{ #category : #accessing }
PharoteroItem >> parentCollectionKey [
	self parentCollection ifNil: [ ^ nil ].
	self parentCollection isString ifTrue: [ ^ self parentCollection ].
	^self parentCollection key
]

{ #category : #accessing }
PharoteroItem >> publisher [
	^ publisher
]

{ #category : #accessing }
PharoteroItem >> publisher: anObject [
	publisher := anObject
]

{ #category : #accessing }
PharoteroItem >> title [
	^ title
]

{ #category : #accessing }
PharoteroItem >> title: aString [
	title := aString
]

{ #category : #accessing }
PharoteroItem >> url [
	^ url
]

{ #category : #accessing }
PharoteroItem >> url:aString [
	url := aString
]
