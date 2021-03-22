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
		'userKind',
		'collectionsCache'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'Pharotero-entities'
}

{ #category : #accessing }
PharoteroServer class >> instance [ 
	^instance ifNil: [ instance := self new ]
]

{ #category : #accessing }
PharoteroServer class >> resetInstance [ 
	instance := nil
]

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
PharoteroServer >> addItem: pharoteroItem type: itemType in: collectionName [
	| newItem |
	newItem := (NeoJSONReader on: (self newItem: itemType) readStream)
		nextAs: PharoteroItem.
	newItem
		copyFrom: pharoteroItem ;
		parentCollection: (self collectionNamed: collectionName) ;
		date: Date today yyyymmdd.
	self putItem: newItem
]

{ #category : #api }
PharoteroServer >> allCollections [
	^self topCollections
		flatCollect: [ :coll | coll getAllSubCollectionsFrom: self ]

]

{ #category : #api }
PharoteroServer >> collectionNamed: aString [
	^self allCollections
		detect: [ :coll | coll name = aString ]
		ifNone: [ nil ]
]

{ #category : #accessing }
PharoteroServer >> collectionsFilename [
	^'/home/anquetil/.zotero/zoteroCollections.ston'
]

{ #category : #api }
PharoteroServer >> desktopClientIsUp [
	^[(ZnClient new
		url: 'http://127.0.0.1:23119/connector/ping' ;
		get ;
		response) status = 200]
	on: ConnectionTimedOut
	do: [ false ] .
]

{ #category : #api }
PharoteroServer >> desktopCurrentCollection [
	| znEntity jsonResponse |
	znEntity := ZnEntity text: '{"X-Zotero-Connector-API-Version":"2"}'.
	znEntity contentType: ZnMimeType applicationJson.

	jsonResponse := ZnClient new
		url: 'http://127.0.0.1:23119/connector/getSelectedCollection' ;
		entity: znEntity ;
		post ;
		response.

	jsonResponse status = 200
	ifFalse: [ ^ nil ].
	^(NeoJSONReader fromString: jsonResponse entity string) at: #name
]

{ #category : #queries }
PharoteroServer >> get: aStringQuery [
	^ZnClient new
		contentReader: [ :entity | entity contents ] ;
		enforceHttpSuccess: true ;
		get: (self urlForQuery: aStringQuery)
]

{ #category : #private }
PharoteroServer >> getCollections: query [
	^PharoteroCollection listFromJSON: (self get: query)

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

{ #category : #queries }
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

{ #category : #queries }
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
PharoteroServer >> queryForSubCollectionsOfKey: aCollectionKey [
	^'collections/' , aCollectionKey , '/collections'
]

{ #category : #api }
PharoteroServer >> reloadCollections [
	collectionsCache := self collectionsFilename asFileReference
		readStreamDo: [ :st | STON fromStream: st].

]

{ #category : #api }
PharoteroServer >> resetCollections [
	collectionsCache := nil

]

{ #category : #settings }
PharoteroServer >> rmodIdentity [
	self userKind: 'groups'.
	self identifier: '2068125'.
	self accessKey: 'QpEsv2IZKPBb1K87A9taV8WE'
]

{ #category : #api }
PharoteroServer >> saveCollections [
	self collectionsFilename asFileReference writeStreamDo: [ :st |
		st nextPutAll: (STON toString: collectionsCache) 
	].

]

{ #category : #api }
PharoteroServer >> topCollections [
	^collectionsCache
		ifNil: [ collectionsCache := self getCollections: 'collections/top' ]

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
