package com.everythingportal.javaservice.repository;

import com.everythingportal.javaservice.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for Product entity.
 */
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByActive(Boolean active);

    List<Product> findByNameContainingIgnoreCase(String name);
}
