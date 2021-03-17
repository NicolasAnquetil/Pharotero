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
		'identifier',
		'accessKey',
		'userKind'
	],
	#category : #'Pharotero-entities'
}

{ #category : #accessing }
PharoteroServer class >> zoteroURL [
	^ 'https://api.zotero.org'
]

{ #category : #accessing }
PharoteroServer >> accessKey [
	^ accessKey
]

{ #category : #accessing }
PharoteroServer >> accessKey: aString [
	accessKey := aString
]

{ #category : #api }
PharoteroServer >> collectionNamed: aString [
	^self getAllCollections
		detect: [ :coll | coll name = aString ]
		ifNone: [ nil ]
]

{ #category : #private }
PharoteroServer >> get: aStringQuery [
	^ZnClient new
		contentReader: [ :entity | entity contents ] ;
		enforceHttpSuccess: true ;
		get: (self urlForQuery: aStringQuery)
]

{ #category : #api }
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

{ #category : #accessing }
PharoteroServer >> identifier [
	^identifier
]

{ #category : #accessing }
PharoteroServer >> identifier: anObject [
	identifier := anObject 
]

{ #category : #private }
PharoteroServer >> identity [
	^self userKind , '/' , self identifier
]

{ #category : #api }
PharoteroServer >> itemsIn: aZoteroCollection [
	^aZoteroCollection nbItems = 0
		ifTrue: [ #() ]
		ifFalse: [ | items |
			items := self getItems: (self queryForItemsOfKey: aZoteroCollection key).
			items do: [ :coll | coll parentCollection: aZoteroCollection ].
			^items
		]
]

{ #category : #api }
PharoteroServer >> newItem: itemType [
	^ZnClient new
		contentReader: [ :entity | entity contents ] ;
		enforceHttpSuccess: true ;
		get: ( PharoteroServer zoteroURL , '/items/new?itemType=' , itemType)
]

{ #category : #settings }
PharoteroServer >> nicolasIdentity [
	self userKind: 'users'.
	self identifier: '4572669'.
	self accessKey: 'f3kySrbb1npXJEkqi7C6l5CL'
]

{ #category : #api }
PharoteroServer >> putItem: pharoteroItem [
	| znEntity jsonObject |
	jsonObject := { {'data' -> pharoteroItem} asDictionary }.
	znEntity := ZnEntity text: (NeoJSONWriter toString: jsonObject).
	znEntity contentType: ZnMimeType applicationJson.

	^ZnClient new
		url: (self urlForQuery: 'items') ;
		entity: znEntity ;
		post ;
		response
]

{ #category : #queries }
PharoteroServer >> queryForItemsOfKey: aCollectionKey [
	^'collections/' , aCollectionKey , '/items'.
]

{ #category : #queries }
PharoteroServer >> queryForSubCollectionsOfKey: aCollectionKey [
	^'collections/' , aCollectionKey , '/collections'
]

{ #category : #settings }
PharoteroServer >> rmodIdentity [
	self userKind: 'groups'.
	self identifier: '2068125'.
	self accessKey: 'QpEsv2IZKPBb1K87A9taV8WE'
]

{ #category : #api }
PharoteroServer >> topCollections [
	^self getCollections: 'collections/top'
]

{ #category : #private }
PharoteroServer >> urlForQuery: aStringQuery [
	| hasQuestionMark |
	hasQuestionMark := (aStringQuery indexOf: $?) > 0.

	^String streamContents: [ :st |
		st
			<< PharoteroServer zoteroURL ;
			<< '/' ;
			<< self identity ;
			<< '/' ;
			<< aStringQuery ;
			<< 	(hasQuestionMark ifTrue: [ $& ] ifFalse: [ $? ]) ;
			<<	'v=3&key=' ;
			<< self accessKey.
	]
]

{ #category : #accessing }
PharoteroServer >> userKind [
	^userKind 
]

{ #category : #accessing }
PharoteroServer >> userKind: aString [ 
	userKind := aString 
]
