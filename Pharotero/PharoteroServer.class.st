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

{ #category : #queries }
PharoteroServer >> collectionNamed: aString [
	^self getAllCollections
		detect: [ :coll | coll name = aString ]
		ifNone: [ nil ]
]

{ #category : #accessing }
PharoteroServer >> defaultKey [
	self accessKey: 'QpEsv2IZKPBb1K87A9taV8WE'
]

{ #category : #private }
PharoteroServer >> get: aStringQuery [		
	^ znServer get: (self queryWithAccessKey: aStringQuery)
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
		nextListAs: PharoteroCollection
]

{ #category : #private }
PharoteroServer >> getItems: query [
	"parsing JSON for Zotero items is a bit tricky as we are only interested in the #data filed of the JSON
	 So we use a virtual object #TransferObject that gets the PharoteroItem into a #data instance variable and then we collect these PharoteroItems"
	^((NeoJSONReader on: (self get: query) readStream)
	for: #TransferObject do: [ :mapping |
        mapping subjectClass: NeoJSONObject.
        (mapping mapAccessor: #data) valueSchema: PharoteroItem ] ;
	nextListAs: #TransferObject )
	reject: [ :i | i itemType = 'note' ] thenCollect: #data.

]

{ #category : #private }
PharoteroServer >> getItemsFor: aZoteroCollection [
	^aZoteroCollection nbItems = 0
		ifTrue: [ #() ]
		ifFalse: [ | items |
			items := self getItems: (self queryForItemsOfKey: aZoteroCollection key).
			items do: [ :coll | coll parentCollection: aZoteroCollection ].
			^items
		]
]

{ #category : #private }
PharoteroServer >> getNewItem: itemType [
	^self get: 'items/new?itemType=' , itemType
]

{ #category : #api }
PharoteroServer >> getSubCollectionsFor: aZoteroCollection [
	^aZoteroCollection nbSubCollections = 0
		ifTrue: [ #() ]
		ifFalse: [
			(self getCollections: (self queryForSubCollectionsOfKey: aZoteroCollection key))
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

{ #category : #'as yet unclassified' }
PharoteroServer >> putItem: pharoteroItem inCollection: pharoteroCollection [
	^znServer put: (self queryWithAccessKey: 'items/') contents: ''
]

{ #category : #queries }
PharoteroServer >> queryForItemsOfKey: aCollectionKey [
	^'collections/' , aCollectionKey , '/items'.
]

{ #category : #queries }
PharoteroServer >> queryForSubCollectionsOfKey: aCollectionKey [
	^'collections/' , aCollectionKey , '/collections'
]

{ #category : #private }
PharoteroServer >> queryWithAccessKey: aStringQuery [
	| hasQuestionMark |
	hasQuestionMark := (aStringQuery indexOf: $?) > 0.

	String streamContents: [ :st |
		st
			<< baseURL ;
			<< aStringQuery ;
			<< 	(hasQuestionMark ifTrue: [ $& ] ifFalse: [ $? ]) ;
			<<	'v=3&key=' ;
			<< self accessKey.
	]
]

{ #category : #accessing }
PharoteroServer >> rmodGroupIdentifier [
	"RMod group identifier"
	^ '2068125'
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
