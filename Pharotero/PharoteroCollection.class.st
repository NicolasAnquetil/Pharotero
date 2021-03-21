"
I represents a ""collection"" in a Zotero (http://www.zotero.org) library.
i.e. not a Collection in the pharo sense, but a ""library""

I have a key, a name, an optional parentCollection, and I contain ZoteroItems (i.e. references)

"
Class {
	#name : #PharoteroCollection,
	#superclass : #Object,
	#instVars : [
		'name',
		'key',
		'versionNumber',
		'parentCollection',
		'nbSubCollections',
		'subCollections',
		'nbItems',
		'items'
	],
	#category : #'Pharotero-entities'
}

{ #category : #'instance creation' }
PharoteroCollection class >> listFromJSON: jsonString [
	^(NeoJSONReader on: jsonString readStream)
		nextListAs: PharoteroCollection
]

{ #category : #accessing }
PharoteroCollection class >> neoJsonMapping: mapper [
	mapper
		for: PharoteroCollection do: [ :mapping | 
	      mapping mapInstVar: #key.
			mapping mapInstVar: #versionNumber to: #version.
			(mapping mapInstVar: #name to: #data)
				valueSchema: #dataName.
			mapping mapAccessor: #jsonMeta to: #meta
		].

	mapper
		for: #dataName customDo: [ :mapping |
			mapping decoder: [ :dict | dict at: #name ]
		]

]

{ #category : #queries }
PharoteroCollection >> getAllSubCollectionsFrom: pharoteroServer [
	^((self getSubCollectionsFrom: pharoteroServer)
		flatCollect: [ :coll | coll getAllSubCollectionsFrom: pharoteroServer ])
			, {self}		 
]

{ #category : #queries }
PharoteroCollection >> getSubCollectionsFrom: pharoteroServer [
	nbSubCollections = 0 ifTrue: [ ^#() ].
	nbSubCollections = self subCollections size  ifTrue: [ ^self subCollections ].
	subCollections :=
		(pharoteroServer getCollections: (pharoteroServer queryForSubCollectionsOfKey: key)).
	subCollections do: [ :coll | coll parentCollection: self ].
	^subCollections

]

{ #category : #accessing }
PharoteroCollection >> items [
	^ items
]

{ #category : #accessing }
PharoteroCollection >> items: anObject [
	items := anObject
]

{ #category : #queries }
PharoteroCollection >> itemsFrom: pharoteroServer [
	^nbItems = 0
		ifTrue: [ #() ]
		ifFalse: [
			items := PharoteroItem listFromJSON: (pharoteroServer get: 'collections/' , key , '/items').
			items do: [ :coll | coll parentCollection: self ].
			items
		]
]

{ #category : #accessing }
PharoteroCollection >> jsonMeta [
	self shouldBeImplemented
]

{ #category : #accessing }
PharoteroCollection >> jsonMeta: neoJsonObject [
	nbSubCollections := neoJsonObject at: #numCollections.
	nbItems := neoJsonObject at: #numItems.

]

{ #category : #accessing }
PharoteroCollection >> key [
	^ key
]

{ #category : #accessing }
PharoteroCollection >> key: anObject [
	key := anObject
]

{ #category : #accessing }
PharoteroCollection >> name [
	^ name
]

{ #category : #accessing }
PharoteroCollection >> name: anObject [
	name := anObject
]

{ #category : #accessing }
PharoteroCollection >> nbItems [
	^ nbItems
]

{ #category : #accessing }
PharoteroCollection >> nbItems: anObject [
	nbItems := anObject
]

{ #category : #accessing }
PharoteroCollection >> nbSubCollections [
	^ nbSubCollections
]

{ #category : #accessing }
PharoteroCollection >> nbSubCollections: anObject [
	nbSubCollections := anObject
]

{ #category : #accessing }
PharoteroCollection >> parentCollection [
	^ parentCollection
]

{ #category : #accessing }
PharoteroCollection >> parentCollection: anObject [
	parentCollection := anObject
]

{ #category : #accessing }
PharoteroCollection >> subCollections [
	^ subCollections ifNil: [ #() ]
]

{ #category : #accessing }
PharoteroCollection >> subCollections: anObject [
	subCollections := anObject
]

{ #category : #accessing }
PharoteroCollection >> versionNumber [
	^versionNumber
]

{ #category : #accessing }
PharoteroCollection >> versionNumber: aNumber [
	versionNumber := aNumber 
]
