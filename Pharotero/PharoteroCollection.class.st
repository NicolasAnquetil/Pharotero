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
		'parentCollection',
		'nbSubCollections',
		'subCollections',
		'nbItems',
		'items'
	],
	#category : #'Pharotero-entities'
}

{ #category : #accessing }
PharoteroCollection class >> neoJsonMapping: mapper [
	mapper
		for: PharoteroCollection do: [ :mapping | 
	      mapping mapInstVar: #key.
			(mapping mapInstVar: #name to: #data)
				valueSchema: #name.
			mapping mapAccessor: #jsonMeta to: #meta
		].

	mapper
		for: #name customDo: [ :mapping |
			mapping decoder: [ :dict | dict at: #name ]
		]

]

{ #category : #accessing }
PharoteroCollection >> items [
	^ items
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
PharoteroCollection >> nbSubCollections [
	^ nbSubCollections
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
	^ subCollections
]
