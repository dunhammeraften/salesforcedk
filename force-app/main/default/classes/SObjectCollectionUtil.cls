public with sharing class SObjectCollectionUtil {
	private final List<SObject> records;

	public static SObjectCollectionUtil of(Iterable<SObject> records) {
		return new SObjectCollectionUtil(records);
	}

	private SObjectCollectionUtil(Iterable<SObject> records) {
		this.records = new List<SObject>();
		for (SObject record : records) {
			this.records.add(record);
		}
	}

	public Integer size() {
		return this.records.size();
	}

	public List<SObject> asList() {
		return new List<SObject>(this.records);
	}

	public Map<Id, SObject> asMap() {
		return new Map<Id, SObject>(this.records);
	}

	public Boolean isEmpty() {
		return this.records.isEmpty();
	}

	public List<Boolean> pluckBooleans(Schema.SObjectField field) {
		List<Boolean> results = new List<Boolean>();
		for (SObject rec : this.records) {
			results.add((Boolean) rec.get(field));
		}
		return results;
	}

	public List<Boolean> pluckBooleans(String relation) {
		List<Boolean> results = new List<Boolean>();
		for (SObject rec : this.records) {
			results.add((Boolean) this.read(rec, relation));
		}
		return results;
	}

	public List<Date> pluckDates(Schema.SObjectField field) {
		List<Date> results = new List<Date>();
		for (SObject rec : this.records) {
			results.add((Date) rec.get(field));
		}
		return results;
	}

	public List<Date> pluckDates(String relation) {
		List<Date> results = new List<Date>();
		for (SObject rec : this.records) {
			results.add((Date) this.read(rec, relation));
		}
		return results;
	}

	public List<Datetime> pluckDatetimes(Schema.SObjectField field) {
		List<Datetime> results = new List<Datetime>();
		for (SObject rec : this.records) {
			results.add((Datetime) rec.get(field));
		}
		return results;
	}

	public List<Datetime> pluckDatetimes(String relation) {
		List<Datetime> results = new List<Datetime>();
		for (SObject rec : this.records) {
			results.add((Datetime) this.read(rec, relation));
		}
		return results;
	}

	public List<Decimal> pluckDecimals(Schema.SObjectField field) {
		List<Decimal> results = new List<Decimal>();
		for (SObject rec : this.records) {
			results.add((Decimal) rec.get(field));
		}
		return results;
	}

	public List<Decimal> pluckDecimals(String relation) {
		List<Decimal> results = new List<Decimal>();
		for (SObject rec : this.records) {
			results.add((Decimal) this.read(rec, relation));
		}
		return results;
	}

	public List<Id> pluckIds() {
		List<Id> results = new List<Id>();
		for (SObject rec : this.records) {
			results.add(rec.Id);
		}
		return results;
	}

	public List<Id> pluckIds(Schema.SObjectField field) {
		List<Id> results = new List<Id>();
		for (SObject rec : this.records) {
			results.add((Id) rec.get(field));
		}
		return results;
	}

	public List<Id> pluckIds(String relation) {
		List<Id> results = new List<Id>();
		for (SObject rec : this.records) {
			results.add((Id) this.read(rec, relation));
		}
		return results;
	}

	public List<String> pluckStrings(Schema.SObjectField field) {
		List<String> results = new List<String>();
		for (SObject rec : this.records) {
			results.add((String) rec.get(field));
		}
		return results;
	}

	public List<String> pluckStrings(String relation) {
		List<String> results = new List<String>();
		for (SObject rec : this.records) {
			results.add((String) this.read(rec, relation));
		}
		return results;
	}

	public Map<Boolean, List<SObject>> groupByBooleans(String apiFieldName) {
		Map<Boolean, List<SObject>> grouped = new Map<Boolean, List<SObject>>();
		for (SObject rec : this.records) {
			Boolean key = (Boolean) rec.get(apiFieldName);
			if (!grouped.containsKey(key)) {
				grouped.put(key, new List<SObject>());
			}
			grouped.get(key).add(rec);
		}
		return grouped;
	}

	public Map<Boolean, List<SObject>> groupByBooleans(Schema.SObjectField field) {
		return groupByBooleans(field.getDescribe().getName());
	}

	public Map<Date, List<SObject>> groupByDates(String apiFieldName) {
		Map<Date, List<SObject>> grouped = new Map<Date, List<SObject>>();
		for (SObject rec : this.records) {
			Date key = (Date) rec.get(apiFieldName);
			if (!grouped.containsKey(key)) {
				grouped.put(key, new List<SObject>());
			}
			grouped.get(key).add(rec);
		}
		return grouped;
	}

	public Map<Date, List<SObject>> groupByDates(Schema.SObjectField field) {
		return groupByDates(field.getDescribe().getName());
	}

	public Map<Datetime, List<SObject>> groupByDatetimes(String apiFieldName) {
		Map<Datetime, List<SObject>> grouped = new Map<Datetime, List<SObject>>();
		for (SObject rec : this.records) {
			Datetime key = (Datetime) rec.get(apiFieldName);
			if (!grouped.containsKey(key)) {
				grouped.put(key, new List<SObject>());
			}
			grouped.get(key).add(rec);
		}
		return grouped;
	}

	public Map<Datetime, List<SObject>> groupByDatetimes(Schema.SObjectField field) {
		return groupByDatetimes(field.getDescribe().getName());
	}

	public Map<Decimal, List<SObject>> groupByDecimals(String apiFieldName) {
		Map<Decimal, List<SObject>> grouped = new Map<Decimal, List<SObject>>();
		for (SObject rec : this.records) {
			Decimal key = (Decimal) rec.get(apiFieldName);
			if (!grouped.containsKey(key)) {
				grouped.put(key, new List<SObject>());
			}
			grouped.get(key).add(rec);
		}
		return grouped;
	}

	public Map<Decimal, List<SObject>> groupByDecimals(Schema.SObjectField field) {
		return groupByDecimals(field.getDescribe().getName());
	}

	public Map<Id, List<SObject>> groupByIds(String apiFieldName) {
		Map<Id, List<SObject>> grouped = new Map<Id, List<SObject>>();
		for (SObject rec : this.records) {
			Id key = (Id) rec.get(apiFieldName);
			if (!grouped.containsKey(key)) {
				grouped.put(key, new List<SObject>());
			}
			grouped.get(key).add(rec);
		}
		return grouped;
	}

	public Map<Id, List<SObject>> groupByIds(Schema.SObjectField field) {
		return groupByIds(field.getDescribe().getName());
	}

	public Map<String, List<SObject>> groupByStrings(String apiFieldName) {
		Map<String, List<SObject>> grouped = new Map<String, List<SObject>>();
		for (SObject rec : this.records) {
			String key = (String) rec.get(apiFieldName);
			if (!grouped.containsKey(key)) {
				grouped.put(key, new List<SObject>());
			}
			grouped.get(key).add(rec);
		}
		return grouped;
	}

	public Map<String, List<SObject>> groupByStrings(Schema.SObjectField field) {
		return groupByStrings(field.getDescribe().getName());
	}

	public SObjectCollectionUtil pick(List<Schema.SObjectField> fields) {
		return pick(new Set<Schema.SObjectField>(fields));
	}

	public SObjectCollectionUtil pick(Set<Schema.SObjectField> fields) {
		Set<String> fieldNames = new Set<String>();
		for (Schema.SObjectField field : fields) {
			Schema.DescribeFieldResult describe = field.getDescribe();
			fieldNames.add(describe.getName());
		}
		return pick(fieldNames);
	}

	public SObjectCollectionUtil pick(Set<String> apiFieldNames) {
		List<SObject> picked = new List<SObject>();
		for (SObject record : this.records) {
			SObject result = record.getSObjectType().newSObject();
			Map<String, Object> fieldMap = record.getPopulatedFieldsAsMap();
			for (String fieldName : apiFieldNames) {
				if (fieldMap.containsKey(fieldName)) {
					result.put(fieldName, record.get(fieldName));
				}
			}
			picked.add(result);
		}
		return SObjectCollectionUtil.of(picked);
	}

	public SObjectCollectionUtil pick(List<String> apiFieldNames) {
		return pick(new Set<String>(apiFieldNames));
	}

	static Map<String, String[]> relationPartsCache = new Map<String, String[]>();

	private String[] relationParts(String relation) {
		String[] parts = relationPartsCache.get(relation);
		if (parts == null) {
			parts = relation.split('\\.');
			relationPartsCache.put(relation, parts);
		}
		return parts;
	}

	public Object read(SObject record, String relation) {
		if (record == null) {
			throw new IllegalArgumentException('Provided record is null');
		}
		if (String.isBlank(relation)) {
			throw new IllegalArgumentException('Provided relation is blank');
		}
		String[] pathParts = relationParts(relation);
		SObject currentRecord = record;
		for (Integer i = 0; i < pathParts.size() - 1; i++) {
			String relationPart = pathParts[i];
			try {
				SObject nextRecord = currentRecord.getSObject(relationPart);
				if (nextRecord == null) {
					throw new IllegalArgumentException(
						String.format(
							'Cannot resolve "{0}" ({1}) on {2} object',
							new List<String>{
								relationPart,
								relation,
								currentRecord.getSObjectType().getDescribe().getName()
							}
						)
					);
				}
				currentRecord = currentRecord.getSObject(relationPart);
			} catch (SObjectException e) {
				throw new IllegalArgumentException(
					String.format(
						'Cannot resolve "{0}" ({1}) on {2} object',
						new List<String>{
							relationPart,
							relation,
							currentRecord.getSObjectType().getDescribe().getName()
						}
					)
				);
			}
		}
		String lastPart = pathParts[pathParts.size() - 1];

		Object fieldValue;
		try {
			fieldValue = currentRecord.get(lastPart);
		} catch (SObjectException e) {
			throw new IllegalArgumentException(
				String.format(
					'Cannot resolve "{0}" ({1}) on {2} object',
					new List<String>{ lastPart, relation, currentRecord.getSObjectType().getDescribe().getName() }
				)
			);
		}
		return fieldValue;
	}
}