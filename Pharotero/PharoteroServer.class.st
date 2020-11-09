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

{ #category : #private }
PharoteroServer >> get: aStringQuery [
	^ znServer get: baseURL , aStringQuery , '?v=3&key=' , self accessKey
]

{ #category : #api }
PharoteroServer >> getAllCollections [
	^self topCollections
		flatCollect: [ :coll | self getSubCollectionsFor: coll ]

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
		ifFalse: [ self itemsOf: aZoteroCollection key ]
]

{ #category : #api }
PharoteroServer >> getSubCollectionsFor: aZoteroCollection [
	^aZoteroCollection nbSubCollections = 0
		ifTrue: [ { aZoteroCollection } ]
		ifFalse: [ | subCollections |
			subCollections := self subCollectionsOf: aZoteroCollection key.
			subCollections do: [ :coll | coll parentCollection: aZoteroCollection ].
			subCollections
				flatCollect: [ :coll | self getSubCollectionsFor: coll ]
		]
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
PharoteroServer >> itemsOf: collectionKey [
	^self getCollections: 'collections/' , collectionKey , '/items'
]

{ #category : #accessing }
PharoteroServer >> rmodGroupIdentifier [
	"RMod group identifier"
	^ '2068125'
]

{ #category : #queries }
PharoteroServer >> subCollectionsOf: collectionKey [
	^self getCollections: 'collections/' , collectionKey , '/collections'
]

{ #category : #queries }
PharoteroServer >> topCollections [
	^self getCollections: 'collections/top'
]

{ #category : #accessing }
PharoteroServer >> url: aString [
	"(aString beginsWith: 'http://')
	ifTrue: [ url := aString copyFrom: 8 to: aString size]
	ifFalse: [url := aString ].

	(url endsWith: '/')
	ifFalse: [ url := url , '/' ]."
	baseURL := aString.
	znServer url: aString
]
