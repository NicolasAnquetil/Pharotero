"
I represent a client of the Zotero site using its REST API

Example:
[[[
	PharoteroServer rmodGroupLibrary
		accessKey: 'putYourZoteroKeyHere' ;
		getAllCollections
]]]

will return a list of all Collections in the Zotero library of RMod group
"
Class {
	#name : #PharoteroServer,
	#superclass : #Object,
	#instVars : [
		'baseURL',
		'znServer',
		'accessKey'
	],
	#category : #Pharotero
}

{ #category : #'instance creation' }
PharoteroServer class >> rmodGroupLibrary [
	| instance |
	instance := self new.
	instance baseUrlDefaultGroup.
	^ instance 
		
]

{ #category : #accessing }
PharoteroServer class >> zoteroURL [
	^ 'https://api.zotero.org/'
]

{ #category : #accessing }
PharoteroServer >> accessKey [
	^ accessKey
]

{ #category : #accessing }
PharoteroServer >> accessKey: aString [
	accessKey := aString
]

{ #category : #accessing }
PharoteroServer >> baseUrlDefaultGroup [
	self url: PharoteroServer zoteroURL , 'groups/' , self rmodGroupIdentifier , '/'
]

{ #category : #accessing }
PharoteroServer >> defaultKey [
	self accessKey: 'QpEsv2IZKPBb1K87A9taV8WE'
]

{ #category : #private }
PharoteroServer >> get: aStringQuery [
	| hasQuestionMark urlQuery |
	hasQuestionMark := (aStringQuery indexOf: $?) > 0.
	urlQuery := String streamContents: [ :st |
		st
			<< baseURL ;
			<< aStringQuery ;
			<< 	(hasQuestionMark ifTrue: [ $& ] ifFalse: [ $? ]) ;
			<<	'v=3&key=' ;
			<< self accessKey.
	].
		
	^ znServer get: urlQuery
]

{ #category : #queries }
PharoteroServer >> getAllCollections [
	^self topCollections
		flatCollect: [ :coll | self getAllSubCollectionsFor: coll ]

]

{ #category : #api }
PharoteroServer >> getAllSubCollectionsFor: aZoteroCollection [
	^((self getSubCollectionsFor: aZoteroCollection)
		flatCollect: [ :coll | self getAllSubCollectionsFor: coll ])
			, {aZoteroCollection}		 
]

{ #category : #private }
PharoteroServer >> getCollections: query [
	^(NeoJSONReader
		on: (self get: query) readStream)
		for: #ArrayOfZoteroCollection customDo: [ :mapping |
			mapping listOfElementSchema: PharoteroCollection ];
		nextAs: #ArrayOfZoteroCollection.
]

{ #category : #private }
PharoteroServer >> getItems: query [
	^(NeoJSONReader
		on: (self get: query) readStream)
		for: #ArrayOfZoteroItems customDo: [ :mapping |
			mapping listOfElementSchema: PharoteroItem ];
		nextAs: #ArrayOfZoteroItems.
]

{ #category : #private }
PharoteroServer >> getItemsFor: aZoteroCollection [
	^aZoteroCollection nbItems = 0
		ifTrue: [ #() ]
		ifFalse: [ | items |
			items := self itemsOfKey: aZoteroCollection key.
			items do: [ :coll | coll parentCollection: aZoteroCollection ].
			^items
		]
]

{ #category : #api }
PharoteroServer >> getSubCollectionsFor: aZoteroCollection [
	^aZoteroCollection nbSubCollections = 0
		ifTrue: [ #() ]
		ifFalse: [
			(self subCollectionsOfKey: aZoteroCollection key)
				do: [ :coll | coll parentCollection: aZoteroCollection ] ;
				yourself
		]
]

{ #category : #private }
PharoteroServer >> getTemplate: documentType [
	^(NeoJSONReader
		on: (self get: 'new?itemType=' , documentType) readStream)
		for: #ArrayOfZoteroItems customDo: [ :mapping |
			mapping listOfElementSchema: PharoteroItem ];
		nextAs: #ArrayOfZoteroItems.
]

{ #category : #initialization }
PharoteroServer >> initialize [
	znServer := ZnClient new
		contentReader: [ :entity | entity contents ] ;
		contentWriter: [ :data |
			self notYetImplemented 
			"ZnEntity with: (NeoJSONWriter toString: data) type: ZnMimeType applicationJson" ];
		enforceHttpSuccess: true;
		yourself
]

{ #category : #queries }
PharoteroServer >> itemsOfKey: aCollectionKey [
	^self getCollections: 'collections/' , aCollectionKey , '/items'.
]

{ #category : #accessing }
PharoteroServer >> rmodGroupIdentifier [
	"RMod group identifier"
	^ '2068125'
]

{ #category : #queries }
PharoteroServer >> subCollectionsOfKey: aCollectionKey [
	^self getCollections: 'collections/' , aCollectionKey , '/collections'
]

{ #category : #queries }
PharoteroServer >> topCollections [
	^self getCollections: 'collections/top'
]

{ #category : #accessing }
PharoteroServer >> url: aString [
	baseURL := aString.
	znServer url: aString
]
