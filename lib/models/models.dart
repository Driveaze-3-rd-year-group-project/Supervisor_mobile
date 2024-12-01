class Job {
  final int jobId;
  final String startedDate;
  final String jobDescription;
  final int vehicleId;
  final String startTime;
  final int supervisorId;
  final int serviceTypeId;
  final int vehicleMilage;
  final int jobStatus;

  Job(this.jobId, this.vehicleId, this.startTime, this.supervisorId, this.serviceTypeId, this.vehicleMilage, this.startedDate, this.jobStatus, this.jobDescription);

  Map<String, dynamic> toJson() {
    return {
    'jobId':jobId,
    'startedDate':startedDate,
    'jobDescription':jobDescription,
    'vehicleId':vehicleId,
    'startTime':startTime,
    'supervisorId':supervisorId,
    'serviceTypeId':serviceTypeId,
    'vehicleMilage':vehicleMilage,
    'jobStatus':jobStatus
    };
  }
}

class Vehicle {
  final int vehicleId;
  final String vehicleNo;
  final String brand;
  final String model;
  final String startDate;
  final List<Job> jobs;
  final List<Service> service;


  Vehicle(this.vehicleId, this.vehicleNo, this.brand, this.model, this.startDate, this.jobs, this.service);
}

class Service {
  final int serviceId;
  final String serviceName;

  Service(this.serviceId, this.serviceName);
}